# frozen_string_literal: true

require 'openai'

# https://platform.openai.com/docs/models/gpt-3-5
GPT_MODEL = 'gpt-3.5-turbo-1106'
GPT_CONTEXT_TOKEN_LIMIT = 16_385
GPT_RESPONSE_TOKEN_LIMIT = 4096

class Query
  attr_reader :openai, :embedder, :context_embeddings

  def initialize(context_embeddings)
    @openai = OpenAI::Client.new(access_token: ENV.fetch('OPENAI_API_KEY'))
    @embedder = Embedding.new
    @context_embeddings = context_embeddings
  end

  def ask(question)
    fine_tuning_prompt = 'Answer questions from curious entrepreneurs about the book The Mom Test by Rob Fitzpatrick.'
    user_prompt = 'Use the provided passages from the book The Mom Test to answer the following question\n'
    user_prompt += "Question: #{question}\n"

    # The combined token count of the model's response and the provided prompts cannot exceed GPT_CONTEXT_TOKEN_LIMIT.
    # We can adjust the max response length via the `max_tokens` parameter, but for now have left that at the default
    # of GPT_RESPONSE_TOKEN_LIMIT.
    # https://community.openai.com/t/clarification-for-max-tokens/19576/3
    available_context_tokens = GPT_CONTEXT_TOKEN_LIMIT - (
      OpenAI.rough_token_count(fine_tuning_prompt) +
      OpenAI.rough_token_count(user_prompt) +
      GPT_RESPONSE_TOKEN_LIMIT
    )

    if available_context_tokens.negative?
      raise TokenLimitError, "Question is too long, please provide a shorter question.
                              Question contains #{available_context_tokens * -1} too many tokens.".squish
    end

    most_relevant_passages = embedder.most_relevant_embeddings(question, context_embeddings)

    most_relevant_passages.each do |(_relevance, text)|
      passage = "Passage: #{text}\n"
      passage_token_count = OpenAI.rough_token_count(passage)

      next if (available_context_tokens - passage_token_count).negative?

      available_context_tokens -= passage_token_count
      user_prompt += passage
    end

    response = openai.chat(parameters:
                            {
                              model: GPT_MODEL,
                              temperature: 0.2,
                              max_tokens: GPT_RESPONSE_TOKEN_LIMIT,
                              messages: [
                                { role: 'system', content: fine_tuning_prompt },
                                { role: 'user', content: user_prompt }
                              ]
                            })

    response.dig('choices', 0, 'message', 'content')
  end
end
