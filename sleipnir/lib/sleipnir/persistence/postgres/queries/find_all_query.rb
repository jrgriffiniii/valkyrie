# frozen_string_literal: true
module Sleipnir::Persistence::Postgres::Queries
  class FindAllQuery
    attr_reader :model
    def initialize(model: nil)
      @model = model
    end

    def run
      relation.lazy.map do |orm_object|
        ::Sleipnir::Persistence::Postgres::ResourceFactory.to_model(orm_object)
      end
    end

    private

      def relation
        if !model
          orm_model.all
        else
          orm_model.where(internal_model: model.to_s)
        end
      end

      def orm_model
        Sleipnir::Persistence::Postgres::ORM::Resource
      end
  end
end
