# frozen_string_literal: true

class AddBookPassages < ActiveRecord::Migration[7.1]
  def up
    create_table :book_passages do |t|
      t.text :text, null: false

      t.timestamps
    end

    execute("ALTER TABLE book_passages ADD COLUMN embedding vector(#{::Embedding::EMBEDDING_VECTOR_SIZE}) NOT NULL;")
  end

  def down
    drop_table :book_passages
  end
end
