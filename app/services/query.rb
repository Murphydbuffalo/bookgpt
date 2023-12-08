# frozen_string_literal: true

class Query
  # NOTE: As of this writing 1106 is the latest GPT 3.5 Turbo model,
  # with significantly higher token limits than earlier versions.
  # It will become the default GPT 3.5 model on December 11, 2023,
  # at which point we can replace this with `gpt-3.5-turbo`.
  # https://platform.openai.com/docs/models/gpt-3-5
  GPT_MODEL = 'gpt-3.5-turbo-1106'
  GPT_CONTEXT_TOKEN_LIMIT = 16_385
  GPT_RESPONSE_TOKEN_LIMIT = 4096

  attr_reader :openai, :embedder, :conversation

  def initialize(conversation = nil)
    @openai = OpenAI::Client.new(access_token: ENV.fetch('OPENAI_API_KEY'))
    @embedder = Embedding.new
    @conversation = conversation
  end

  def ask(question_embedding)
    highly_similar_question(question_embedding) || fetch_openai_answer(question_embedding)
  end

  private

  # TODO: DRY out vector query code
  def highly_similar_question(question_embedding)
    vector = Pgvector.encode(question_embedding[:embedding])
    query = ActiveRecord::Base.sanitize_sql_array([
                                                    "SELECT id, content, conversation_id,
                                                     1 - (embedding <=> ?) AS cosine_similarity
                                                     FROM messages
                                                     WHERE role = 'user' AND 1 - (embedding <=> ?) > 0.85
                                                     ORDER BY 1 - (embedding <=> ?) DESC LIMIT 1",
                                                    vector,
                                                    vector,
                                                    vector
                                                  ])
    most_similar_question = ActiveRecord::Base.connection.execute(query).to_a.first

    return if most_similar_question.nil?

    Rails.logger.info("For question '#{question_embedding[:text]}, found a similar question
                       (cosine similarity = #{most_similar_question['cosine_similarity']}) that's already
                       been answered: #{most_similar_question['content']}. Not going to call OpenAI API.".squish)

    conversation = Conversation.find(most_similar_question['conversation_id'])

    # Get the system message immediately following the question, use that as the answer
    sorted_messages = conversation.messages.order(:created_at)
    question_index = nil
    answer = sorted_messages.each_with_index.find do |message, i|
      question_index = i if message.id == most_similar_question['id']

      question_index.present? && i == question_index + 1 && message.role == 'system'
    end

    # Because we used `each_with_index` `answer` is a two element array
    # where the first element is the Message and the second element is its index.
    # So we need to grab the first element.
    answer&.first&.content
  end

  def fetch_openai_answer(question_embedding)
    question_message = { role: 'user', content: question_embedding[:text] }
    messages = fine_tuning_messages + conversation_messages + [question_message]
    message_token_count = OpenAI.rough_token_count(messages.map { |m| m[:content] }.join(' '))

    # The combined token count of the model's response and the provided prompts cannot exceed GPT_CONTEXT_TOKEN_LIMIT.
    # We can adjust the max response length via the `max_tokens` parameter, but for now have left that at the default
    # of GPT_RESPONSE_TOKEN_LIMIT.
    # https://community.openai.com/t/clarification-for-max-tokens/19576/3
    available_context_tokens = GPT_CONTEXT_TOKEN_LIMIT - message_token_count - GPT_RESPONSE_TOKEN_LIMIT

    if available_context_tokens.negative?
      raise TokenLimitError, "Question is too long, please provide a shorter question.
                              Question contains #{available_context_tokens * -1} too many tokens.".squish
    end

    most_relevant_passages(question_embedding).each do |(text)|
      passage = "Passage: #{text}\n"
      passage_token_count = OpenAI.rough_token_count(passage)

      next if (available_context_tokens - passage_token_count).negative?

      available_context_tokens -= passage_token_count
      question_message[:content] += passage
    end

    Rails.logger.info('Calling OpenAI Text Generation API')
    response = openai.chat(parameters:
                            {
                              model: GPT_MODEL,
                              temperature: 0.2,
                              max_tokens: GPT_RESPONSE_TOKEN_LIMIT,
                              messages:
                            })

    response.dig('choices', 0, 'message', 'content')
  end

  def most_relevant_passages(question_embedding, limit = 10)
    # Order by most similar embedding vectors: https://github.com/pgvector
    query = ActiveRecord::Base.sanitize_sql_array([
                                                    'SELECT text FROM book_passages ORDER BY embedding <=> ? LIMIT ?',
                                                    Pgvector.encode(question_embedding[:embedding]),
                                                    limit
                                                  ])
    ActiveRecord::Base.connection.execute(query).to_a.map { |p| p['text'] }
  end

  def fine_tuning_messages
    [{
      role: 'system',
      content: "Use the provided passages to answer questions about the book The Mom Test by Rob Fitzpatrick.
                Don't mention the fact that you're using provided passages.
                Keep your answers to a max of a few short sentences.
                If you're not confident of the answer, or the question seems non-sensical say something like
                \"I'm not sure what you're asking.\"".squish
    }]
  end

  def conversation_messages
    return [] if conversation.blank?

    conversation.messages.sort_by(&:created_at).map do |message|
      {
        role: message.role,
        content: message.content
      }
    end
  end
end
