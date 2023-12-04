# frozen_string_literal: true

class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.text :role, null: false
      t.text :content, null: false
      t.references :conversation, index: true, foreign_key: true, null: false

      t.timestamps
    end

    execute <<-SQL
      ALTER TABLE messages
      ADD CONSTRAINT role_type
      CHECK (role IN ('system', 'user'));
    SQL
  end
end
