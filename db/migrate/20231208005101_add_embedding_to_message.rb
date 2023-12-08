# frozen_string_literal: true

class AddEmbeddingToMessage < ActiveRecord::Migration[7.1]
  def up
    execute("ALTER TABLE messages ADD COLUMN embedding vector(#{::Embedding::EMBEDDING_VECTOR_SIZE});")
  end

  def down
    execute('ALTER TABLE messages DROP COLUMN embedding;')
  end
end
