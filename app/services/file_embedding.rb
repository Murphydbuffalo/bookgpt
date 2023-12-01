# frozen_string_literal: true

require 'pdf-reader'

class FileEmbedding
  attr_reader :filepath, :embedder

  def initialize(filepath)
    @filepath = filepath
    @embedder = Embedding.new
  end

  def write
    reader = PDF::Reader.new(filepath)

    embeddings = reader.pages.flat_map do |page|
      embedder.generate_embeddings(page.text)
    end

    File.write(embedding_filename, embeddings.to_json)
  end

  def read
    JSON.parse(
      File.read(embedding_filename),
      symbolize_names: true
    )
  end

  private

  def embedding_filename
    "#{File.basename(filepath, '.*')}_embeddings.json"
  end
end
