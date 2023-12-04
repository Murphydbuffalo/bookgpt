# frozen_string_literal: true

class Conversation < ApplicationRecord
  has_many :messages

  validates_presence_of :title, :user_id
  validates_uniqueness_of :title, scope: :user_id
end
