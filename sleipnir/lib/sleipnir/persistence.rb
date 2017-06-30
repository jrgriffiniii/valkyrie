# frozen_string_literal: true
module Sleipnir
  module Persistence
    require 'sleipnir/persistence/memory'
    require 'sleipnir/persistence/postgres'
    require 'sleipnir/persistence/solr'
    class ObjectNotFoundError < StandardError
    end
  end
end
