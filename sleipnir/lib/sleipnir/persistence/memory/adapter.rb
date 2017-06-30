# frozen_string_literal: true
module Sleipnir::Persistence::Memory
  class Adapter
    attr_writer :cache
    def resource_factory; end

    def persister
      Sleipnir::Persistence::Memory::Persister.new(self)
    end

    def query_service
      Sleipnir::Persistence::Memory::QueryService.new(adapter: self)
    end

    def cache
      @cache ||= {}
    end
  end
end
