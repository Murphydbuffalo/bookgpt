# frozen_string_literal: true

require 'pdf-reader'
require './embedding'

class FileEmbedding
  attr_reader :filepath, :embedder

  def initialize(filepath)
    @filepath = filepath
    @embedder = Embedding.new
  end

  def save
    reader = PDF::Reader.new(filepath)

    embeddings = reader.pages.flat_map do |page|
      embedder.generate_embeddings(page.text)
    end

    File.write('mom_test_embeddings.json', embeddings.to_json)
  end
end
