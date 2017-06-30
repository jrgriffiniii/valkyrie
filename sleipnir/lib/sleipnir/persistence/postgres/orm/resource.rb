# frozen_string_literal: true
module Sleipnir::Persistence::Postgres
  module ORM
    class Resource < ActiveRecord::Base
      def all_attributes
        attributes.merge(rdf_metadata).symbolize_keys
      end

      def rdf_metadata
        RDFMetadata.new(metadata).result
      end

      class RDFMetadata
        attr_reader :metadata
        def initialize(metadata)
          @metadata = metadata
        end

        def result
          Hash[
            metadata.map do |key, value|
              [key, PostgresValue.for(value).result]
            end
          ]
        end

        class PostgresValue < ::Sleipnir::ValueMapper
        end
        class HashValue < ::Sleipnir::ValueMapper
          PostgresValue.register(self)
          def self.handles?(value)
            value.is_a?(Hash) && value["@value"]
          end

          def result
            RDF::Literal.new(value["@value"], language: value["@language"])
          end
        end

        class IDValue < ::Sleipnir::ValueMapper
          PostgresValue.register(self)
          def self.handles?(value)
            value.is_a?(Hash) && value["id"]
          end

          def result
            Sleipnir::ID.new(value["id"])
          end
        end

        class URIValue < ::Sleipnir::ValueMapper
          PostgresValue.register(self)
          def self.handles?(value)
            value.is_a?(Hash) && value["@id"]
          end

          def result
            ::RDF::URI.new(value["@id"])
          end
        end

        class NestedRecord < ::Sleipnir::ValueMapper
          PostgresValue.register(self)
          def self.handles?(value)
            value.is_a?(Hash) && value.keys.length > 1
          end

          def result
            RDFMetadata.new(value).result.symbolize_keys
          end
        end

        class EnumeratorValue < ::Sleipnir::ValueMapper
          PostgresValue.register(self)
          def self.handles?(value)
            value.respond_to?(:each)
          end

          def result
            value.map do |value|
              calling_mapper.for(value).result
            end
          end
        end
      end
    end
  end
end
