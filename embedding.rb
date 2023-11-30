# frozen_string_literal: true

require 'openai'

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
      { text: section, embedding: generate_embedding(section) }
    end
  end

  def generate_embedding(text)
    # TODO: once we have Rails set up
    # Rails.logger.info('Calling OpenAI embeddings API')
    response = openai.embeddings(parameters: { model: EMBEDDING_MODEL, input: text })
    response['data'].first['embedding']
  end

  private

  def format_text(text)
    # TODO: replace with `squish`
    text.gsub(/\s{2}+/, ' ')
  end

  def split_text(text)
    num_tokens = OpenAI.rough_token_count(text)

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
