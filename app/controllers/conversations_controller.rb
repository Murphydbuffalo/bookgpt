# frozen_string_literal: true

class ConversationsController < ApplicationController
  protect_from_forgery with: :null_session

  # NOTE: For the purposes of this exercise I'm just hardcoding a single user ID
  # to simulate there being support for multiple users, rather than building out
  # the necessary boilerplate for that.
  #
  # If this were a real system we'd of course want authentication and authorization
  # to support different users logging in and only being able to access their conversations.
  USER_ID = 1

  def index
    render json: Conversation.where(user_id: USER_ID).order(created_at: :desc).limit(50).pluck(:id, :title)
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
    @conversation = if params[:conversation_id].present?
                      Conversation.find_by!(user_id: USER_ID, id: params[:conversation_id])
                    else
                      Conversation.new(user_id: USER_ID, title: params[:question].truncate_words(25))
                    end

    question_embedding = Embedding.new.generate_embedding(params[:question])
    answer = Query.new(@conversation).ask(question_embedding)

    Conversation.transaction do
      @conversation.save!
      @conversation.messages.create!(
        role: 'user',
        content: question_embedding[:text],
        embedding: Pgvector.encode(question_embedding[:embedding])
      )
      @conversation.messages.create!(role: 'system', content: answer)
    end

    render json: { answer:, conversation_id: @conversation.id, conversation_title: @conversation.title }
  rescue StandardError => e
    Rails.logger.error(e.message)
    Rails.logger.error(e.backtrace.join("\n"))
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def conversation_params
    params.require(:conversation).permit(:question, :conversation_id)
  end
end
