# frozen_string_literal: true

class ConversationsController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :set_embeddings, only: %i[create]

  # NOTE: For the purposes of this exercise I'm just hardcoding a single user ID
  # to simulate there being support for multiple users, rather than building out
  # the necessary boilerplate for that.
  #
  # If this were a real system we'd of course want authentication and authorization
  # to support different users logging in and only being able to access their conversations.
  USER_ID = 1

  def index
    render json: Conversation.where(user_id: USER_ID).pluck(:id, :title)
  end

  def show
    conversation = Conversation.find_by!(user_id: USER_ID, id: params[:id])
    payload = {
      conversation_id: conversation.id,
      title: conversation.title,
      messages: conversation.messages.map do |m|
        {
          role: m.role,
          content: m.content
        }
      end
    }

    render json: payload
  end

  def create
    question = params[:question]

    @conversation = if params[:conversation_id].present?
                      Conversation.find_by!(user_id: USER_ID, id: params[:conversation_id])
                    else
                      Conversation.new(user_id: USER_ID, title: question.truncate_words(25))
                    end

    answer = Query.new(@embeddings, @conversation).ask(question)

    Conversation.transaction do
      @conversation.save!
      @conversation.messages.create!(role: 'user', content: question)
      @conversation.messages.create!(role: 'system', content: answer)
    end

    render json: { answer:, conversation_id: @conversation.id }
  rescue StandardError => e
    Rails.logger.error(e.backtrace.join("\n"))
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def set_embeddings
    # TODO: put the filepath into a constant or otherwise remove the need to specify it everywhere
    file_embedder = FileEmbedding.new('/Users/danmurphy/Desktop/The-Mom-Test-Print.pdf')
    @embeddings = file_embedder.read
  end

  def conversation_params
    params.require(:conversation).permit(:question, :conversation_id)
  end
end
