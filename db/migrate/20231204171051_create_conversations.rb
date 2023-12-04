# frozen_string_literal: true

class CreateConversations < ActiveRecord::Migration[7.1]
  def change
    create_table :conversations do |t|
      t.text :title, null: false
      t.bigint :user_id, null: false

      t.timestamps
    end

    add_index :conversations, %i[title user_id], unique: true, name: :unique_convo_title_per_user
  end
end
