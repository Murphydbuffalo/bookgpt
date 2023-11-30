# frozen_string_literal: true

require './file_embedding'
require './embedding'

embedder = Embedding.new
file_embedder = FileEmbedding.new('/Users/danmurphy/Desktop/The-Mom-Test-Print.pdf')
# file_embedder.write

embeddings = file_embedder.read
question = "Who wrote The Mom Test and what's it about? Does the author recommend making sure your meetings are sufficiently formal?"
most_relevant = embedder.most_relevant_embeddings(question, embeddings, 10)
prompt = 'Use the provided passages from the book The Mom Test to answer the following question'
