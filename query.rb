# frozen_string_literal: true

require 'openai'
require './file_embedding'
require './embedding'

GPT_MODEL = 'gpt-3.5-turbo'

class Query
  attr_reader :openai, :question, :embedder, :context_embeddings

  def initialize(question, context_embeddings)
    # TODO: put API key in env var
    @openai = OpenAI::Client.new(access_token: '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')
    @question = question
    @embedder = Embedding.new
    @context_embeddings = context_embeddings
  end

  # TODO: do we need to set a max token limit?
  # TODO: make an informed decision about temperature, or make adjustable in the UI
  def ask
    most_relevant_passages = embedder.most_relevant_embeddings(question, context_embeddings)
    fine_tuning_prompt = 'You answer questions from curious entrepreneurs about the book The Mom Test by Rob Fitzpatrick.'
    user_prompt = 'Use the provided passages from the book The Mom Test to answer the following question\n'
    user_prompt += "Question: #{question}\n"

    most_relevant_passages.each do |(_relevance, passage)|
      user_prompt += "Passage: #{passage}\n"
    end

    response = openai.chat(parameters:
                            {
                              model: GPT_MODEL,
                              temperature: 0.2,
                              messages: [
                                { role: 'system', content: fine_tuning_prompt },
                                { role: 'user', content: user_prompt }
                              ]
                            })

    response.dig('choices', 0, 'message', 'content')
  end
end
