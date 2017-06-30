# frozen_string_literal: true
require 'sleipnir/persistence/postgres/orm/resource'
module Sleipnir::Persistence::Postgres
  module ORM
    def self.table_name_prefix
      'orm_'
    end
  end
end
