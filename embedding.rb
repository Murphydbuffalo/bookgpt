# frozen_string_literal: true

require 'openai'
require 'matrix'

# We split text containing more than this number of tokens into smaller subsections
# From the OpenAI docs (https://cookbook.openai.com/examples/embedding_wikipedia_articles_for_search):
# "There's no perfect recipe for splitting text into sections. Some tradeoffs include:
# Longer sections may be better for questions that require more context
# Longer sections may be worse for retrieval, as they may have more topics muddled together
# Shorter sections are better for reducing costs (which are proportional to the number of tokens)
# Shorter sections allow more sections to be retrieved, which may help with recall
# Overlapping sections may help prevent answers from being cut by section boundaries"
MAX_TOKENS = 1600
EMBEDDING_MODEL = 'text-embedding-ada-002'

class Embedding
  attr_reader :openai

  def initialize
    # TODO: put API key in env var
    @openai = OpenAI::Client.new(access_token: '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')
  end

  def generate_embeddings(text)
    sections = split_text(
      format_text(text)
    )

    sections.map do |section|
      generate_embedding(section)
    end
  end

  def generate_embedding(text)
    # TODO: Raise an error if the text is above the token limit, and suggest using
    # generate_embeddings to split the text into sections

    # TODO: once we have Rails set up use Rails.logger.info
    puts 'Calling OpenAI embeddings API'

    response = openai.embeddings(parameters: { model: EMBEDDING_MODEL, input: text })

    { text:, embedding: response['data'].first['embedding'] }
  end

  def most_relevant_embeddings(query, context_embeddings, limit = 5)
    query_embedding = generate_embedding(query)[:embedding]

    context_embeddings.map do |embedding|
      relevance = similarity(query_embedding, embedding[:embedding])

      [relevance, embedding[:text]]
    end.sort_by(&:first).last(limit)
  end

  def similarity(embedding1, embedding2)
    v1 = Vector[*embedding1]
    v2 = Vector[*embedding2]

    # This is the cosine similarity function:
    # https://en.wikipedia.org/wiki/Cosine_similarity
    # "The resulting similarity ranges from -1 meaning exactly opposite,
    # to 1 meaning exactly the same, with 0 indicating orthogonality or decorrelation,
    # while in-between values indicate intermediate similarity or dissimilarity."
    v1.dot(v2) / (v1.magnitude * v2.magnitude)
  end

  private

  def format_text(text)
    # TODO: replace with `squish`
    text.gsub(/\s{2}+/, ' ')
  end

  def split_text(text)
    num_tokens = OpenAI.rough_token_count(text)

    # TODO: If performance isn't good: split text on periods or word breaks,
    # iteratively add those sentences to a string until it exceeds max tokens
    if num_tokens > MAX_TOKENS
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
