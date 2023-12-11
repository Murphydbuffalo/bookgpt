# frozen_string_literal: true

class BookPassage < ApplicationRecord
  validates_presence_of :text
  validates_presence_of :embedding

  def self.import!(filepath:, delete_existing: false)
    embedder = Embedding.new
    reader = PDF::Reader.new(filepath)

    passages = reader.pages.flat_map do |page|
      embedder.generate_embeddings(page.text)
    end

    passages.map! do |passage|
      passage[:embedding] = Pgvector.encode(passage[:embedding])
      passage
    end

    delete_all if delete_existing
    insert_all!(passages)
  end

  def self.export(filepath = './book_passages.json')
    embeddings = all.to_a
    File.write(filepath, embeddings.to_json)
  end
end
