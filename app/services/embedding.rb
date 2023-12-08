# frozen_string_literal: true

class Embedding
  # We split text containing more than this number of tokens into smaller subsections
  # From the OpenAI docs (https://cookbook.openai.com/examples/embedding_wikipedia_articles_for_search):
  # "There's no perfect recipe for splitting text into sections. Some tradeoffs include:
  # Longer sections may be better for questions that require more context
  # Longer sections may be worse for retrieval, as they may have more topics muddled together
  # Shorter sections are better for reducing costs (which are proportional to the number of tokens)
  # Shorter sections allow more sections to be retrieved, which may help with recall
  # Overlapping sections may help prevent answers from being cut by section boundaries"
  #
  # https://openai.com/blog/new-and-improved-embedding-model
  EMBEDDING_MODEL = 'text-embedding-ada-002'
  EMBEDDING_MODEL_TOKEN_LIMIT = 8192
  EMBEDDING_VECTOR_SIZE = 1536

  attr_reader :openai

  def initialize
    @openai = OpenAI::Client.new(access_token: ENV.fetch('OPENAI_API_KEY'))
  end

  def generate_embeddings(text)
    sections = split_text(text.squish)

    sections.map do |section|
      generate_embedding(section)
    end
  end

  def generate_embedding(text)
    token_count = OpenAI.rough_token_count(text)

    if token_count > EMBEDDING_MODEL_TOKEN_LIMIT
      raise TokenLimitError, "Text is too long, consider splitting it into smaller sections using `generate_embeddings`.
                              Text contains #{token_count} tokens, max is #{EMBEDDING_MODEL_TOKEN_LIMIT}.".squish
    end

    Rails.logger.info 'Calling OpenAI embeddings API'

    response = openai.embeddings(parameters: { model: EMBEDDING_MODEL, input: text })

    { text:, embedding: response.dig('data', 0, 'embedding') }
  end

  private

  # NOTE: We could likely improve the performance of the model by splitting split text word breaks
  # to ensure we aren't splitting the middle of a sentence. In practice the model seems to be
  # performing fine without that step, so I've punted on it for now.
  def split_text(text)
    num_tokens = OpenAI.rough_token_count(text)

    if num_tokens > EMBEDDING_MODEL_TOKEN_LIMIT
      halfway_index = text.length / 2
      [
        split_text(text.slice(0..halfway_index)),
        split_text(text.slice((halfway_index + 1)..text.length))
      ]
    else
      [text]
    end.flatten
  end
end
