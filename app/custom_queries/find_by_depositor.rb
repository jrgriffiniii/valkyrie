# frozen_string_literal: true
class FindByDepositor
  def self.queries
    [:find_by_depositor]
  end

  attr_reader :query_service
  def initialize(query_service:)
    @query_service = query_service
  end

  class Memory < FindByDepositor
    def find_by_depositor(depositor:)
      query_service.cache.values.select do |obj|
        obj.respond_to?(:depositor) && obj.depositor.include?(depositor)
      end
    end
  end

  class Postgres < FindByDepositor
    def find_by_depositor(depositor:)
      query_service.run_query(depositor_query, "\"#{depositor}\"")
    end

    def depositor_query
      <<-SQL
        SELECT * FROM orm_resources WHERE
        metadata->'depositor' @> ?
      SQL
    end
  end

  class ActiveFedora < FindByDepositor
    def find_by_depositor(depositor:)
      orm_resource.where(depositor: depositor).lazy.map do |object|
        resource_factory.to_resource(object)
      end
    end

    def orm_resource
      Valkyrie::Persistence::ActiveFedora::ORM::Resource
    end

    def resource_factory
      ::Valkyrie::Persistence::ActiveFedora::ResourceFactory
    end
  end
end
