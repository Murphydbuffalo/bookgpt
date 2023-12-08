# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :conversation

  ROLES = %w[system user].freeze

  validates_presence_of :role, :content
  validates_inclusion_of :role, in: ROLES
  validates_presence_of :embedding, if: ->(message) { message.role == 'user' }
end
