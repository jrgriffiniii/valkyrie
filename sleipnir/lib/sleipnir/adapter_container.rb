# frozen_string_literal: true
module Sleipnir
  class AdapterContainer
    attr_reader :persister, :query_service
    def initialize(persister:, query_service:)
      @persister = persister
      @query_service = query_service
    end
  end
end
