# frozen_string_literal: true

class ConversationsController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :set_conversation, only: %i[show update]
  before_action :set_embeddings, only: %i[create update]

  # NOTE: For the purposes of this exercise I'm just hardcoding a single user ID
  # to simulate there being support for multiple users, rather than building out
  # the necessary boilerplate for that.
  #
  # If this were a real system we'd of course want authentication and authorization
  # to support different users logging in and seeing only their conversations.
  USER_ID = 1

  def index
    conversation_titles_by_id = Conversation.where(user_id: USER_ID).pluck(:id, :title).index_by(&:first)

    render json: conversation_titles_by_id
  end

  def show
    render json: @conversation
  end

  def create
    question = params[:question]
    answer = Query.new(@embeddings).ask(question)
    title = question.truncate_words(25)

    @conversation = Conversation.new(user_id: USER_ID, title:)

    Conversation.transaction do
      @conversation.save!
      @conversation.messages.create!(role: 'user', content: question)
      @conversation.messages.create!(role: 'system', content: answer)
    end

    render json: { answer:, conversation_id: @conversation.id }
  rescue StandardError => e
    Rails.logger.error(e.backtrace.join("\n"))
    render json: e.message, status: :unprocessable_entity
  end

  def update
    question = params[:question]
    answer = Query.new(@embeddings).ask(question)

    Conversation.transaction do
      @conversation.messages.create!(role: 'user', content: question)
      @conversation.messages.create!(role: 'system', content: answer)
    end

    render json: answer
  rescue StandardError => e
    Rails.logger.error(e.backtrace.join("\n"))
    render json: e.message, status: :unprocessable_entity
  end

  private

  def set_conversation
    @conversation = Conversation.where(user_id: USER_ID, id: params[:id]).includes(:messages).first
  end

  def set_embeddings
    # TODO: put the filepath into a constant or otherwise remove the need to specify it everywhere
    file_embedder = FileEmbedding.new('/Users/danmurphy/Desktop/The-Mom-Test-Print.pdf')
    @embeddings = file_embedder.read
  end

  def conversation_params
    params.require(:conversation).permit(:question)
  end
end
