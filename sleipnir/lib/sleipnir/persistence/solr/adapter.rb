# frozen_string_literal: true
require 'rsolr'
module Sleipnir::Persistence::Solr
  require 'sleipnir/persistence/solr/persister'
  require 'sleipnir/persistence/solr/query_service'
  require 'sleipnir/persistence/solr/resource_factory'
  class Adapter
    attr_reader :connection, :resource_indexer
    def initialize(connection:, resource_indexer: NullIndexer)
      @connection = connection
      @resource_indexer = resource_indexer
    end

    def persister
      Sleipnir::Persistence::Solr::Persister.new(adapter: self)
    end

    def query_service
      Sleipnir::Persistence::Solr::QueryService.new(connection: connection, resource_factory: resource_factory)
    end

    def resource_factory
      Sleipnir::Persistence::Solr::ResourceFactory.new(resource_indexer: resource_indexer)
    end

    class NullIndexer
      def initialize(_); end

      def to_solr
        {}
      end
    end
  end
end
