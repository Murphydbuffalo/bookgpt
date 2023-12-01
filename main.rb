# frozen_string_literal: true

file_embedder = FileEmbedding.new('/Users/danmurphy/Desktop/The-Mom-Test-Print.pdf')
file_embedder.write

embeddings = file_embedder.read
question = "Who wrote The Mom Test and what's it about?"
answer = Query.new(embeddings).ask(question)

pp answer.split('.')

# TODO: how can we tell OpenAI to preserve message history? Or do we need to do that on our side?
question = 'Does the author recommend making sure your meetings are sufficiently formal?'
answer = Query.new(embeddings).ask(question)

puts answer
