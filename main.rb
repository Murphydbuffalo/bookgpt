# frozen_string_literal: true

require './file_embedding'

file_embedder = FileEmbedding.new('/Users/danmurphy/Desktop/The-Mom-Test-Print.pdf')
file_embedder.write
embeddings = file_embedder.read
