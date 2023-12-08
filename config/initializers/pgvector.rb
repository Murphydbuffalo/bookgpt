# frozen_string_literal: true

conn = ActiveRecord::Base.connection.raw_connection
registry = PG::BasicTypeRegistry.new.define_default_types
Pgvector::PG.register_vector(registry)
conn.type_map_for_results = PG::BasicTypeMapForResults.new(conn, registry:)
