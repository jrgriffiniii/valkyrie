# frozen_string_literal: true
require 'sleipnir/persistence/postgres/persister'
require 'sleipnir/persistence/postgres/query_service'
module Sleipnir::Persistence::Postgres
  class Adapter
    def self.persister
      Sleipnir::Persistence::Postgres::Persister
    end

    def self.query_service
      Sleipnir::Persistence::Postgres::QueryService
    end
  end
end
