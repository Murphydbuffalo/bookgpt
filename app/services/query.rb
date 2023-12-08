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

    response = openai.chat(parameters:
                            {
                              model: GPT_MODEL,
                              temperature: 0.2,
                              max_tokens: GPT_RESPONSE_TOKEN_LIMIT,
                              messages:
                            })

    response.dig('choices', 0, 'message', 'content')
  end

  private

  def most_relevant_passages(question_embedding, limit = 10)
    # Order by most similar embedding vectors: https://github.com/pgvector
    query = ActiveRecord::Base.sanitize_sql_array([
                                                    'SELECT text FROM book_passages ORDER BY embedding <-> ? LIMIT ?',
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
