# frozen_string_literal: true
module Valkyrie::Persistence::Fedora
  class Persister
    class ModelConverter
      attr_reader :resource, :adapter, :subject_uri
      delegate :connection, :connection_prefix, :base_path, to: :adapter
      def initialize(resource:, adapter:, subject_uri: RDF::URI(""))
        @resource = resource
        @adapter = adapter
        @subject_uri = subject_uri
      end

      def convert
        graph_resource.graph.delete([nil, nil, nil])
        resource.attributes.each do |key, values|
          output = property_converter.for(Property.new(subject_uri, key, values, self)).result
          graph_resource.graph << output.to_graph
        end
        graph_resource
      end

      def graph_resource
        @graph_resource ||= ::Ldp::Container::Basic.new(connection, subject, nil, base_path)
      end

      def subject
        adapter.id_to_uri(resource.id) if resource.try(:id)
      end

      def property_converter
        FedoraValue
      end

      def to_uri(key)
        RDF::URI.new("http://example.com/predicate/#{key}")
      end

      class Property
        attr_reader :key, :value, :subject, :model_converter
        delegate :adapter, :resource, to: :model_converter

        def initialize(subject, key, value, model_converter)
          @subject = subject
          @key = key
          @value = value
          @model_converter = model_converter
        end

        def to_graph(graph = RDF::Graph.new)
          Array(value).each do |val|
            graph << RDF::Statement.new(subject, to_uri, val)
          end
          graph
        end

        def to_uri
          model_converter.to_uri(key)
        end
      end

      class CompositeProperty
        attr_reader :properties
        def initialize(properties)
          @properties = properties
        end

        def to_graph(graph = RDF::Graph.new)
          properties.each do |property|
            property.to_graph(graph)
          end
          graph
        end
      end

      class GraphProperty
        attr_reader :key, :graph, :subject, :model_converter
        delegate :adapter, :resource, to: :model_converter
        def initialize(subject, key, graph, model_converter)
          @subject = subject
          @key = key
          @graph = graph
          @model_converter = model_converter
        end

        def to_graph(passed_graph = RDF::Graph.new)
          passed_graph << graph
        end

        def to_uri
          model_converter.to_uri(key)
        end
      end

      class FedoraValue < ::Valkyrie::ValueMapper
      end

      class OrderedMembers < ::Valkyrie::ValueMapper
        FedoraValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.key == :member_ids && Array(value.value).present?
        end

        def result
          initialize_list
          apply_first_and_last
          GraphProperty.new(value.subject, value.key, graph, value.model_converter)
        end

        def graph
          @graph ||= ordered_list.to_graph
        end

        def apply_first_and_last
          return if ordered_list.to_a.empty?
          graph << RDF::Statement.new(value.subject, ::RDF::Vocab::IANA.first, ordered_list.head.next.rdf_subject)
          graph << RDF::Statement.new(value.subject, ::RDF::Vocab::IANA.last, ordered_list.tail.prev.rdf_subject)
        end

        def initialize_list
          Array(value.value).each_with_index do |val, index|
            ordered_list.insert_proxy_for_at(index, calling_mapper.for(Property.new(value.subject, :member_id, val, value.model_converter)).result.value)
          end
        end

        def ordered_list
          @ordered_list ||= OrderedList.new(RDF::Graph.new, nil, nil, value.adapter)
        end
      end

      class NestedProperty < ::Valkyrie::ValueMapper
        FedoraValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.value.is_a?(Hash) && value.value[:internal_resource]
        end

        def result
          nested_graph << RDF::Statement.new(value.subject, value.to_uri, subject_uri)
          GraphProperty.new(value.subject, value.key, nested_graph, value.model_converter)
        end

        def nested_graph
          @nested_graph ||= ModelConverter.new(resource: Valkyrie::Types::Anything[value.value], adapter: value.adapter, subject_uri: subject_uri).convert.graph
        end

        def subject_uri
          @subject_uri ||= ::RDF::URI(RDF::Node.new.to_s.gsub("_:", "#"))
        end
      end

      class NestedInternalValkyrieID < ::Valkyrie::ValueMapper
        FedoraValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.value.is_a?(Valkyrie::ID) && value.subject.to_s.include?("#")
        end

        def result
          calling_mapper.for(Property.new(value.subject, value.key, RDF::Literal.new(value.value, datatype: RDF::URI("http://example.com/predicate/valkyrie_id")), value.model_converter)).result
        end
      end

      class InternalValkyrieID < ::Valkyrie::ValueMapper
        FedoraValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.value.is_a?(Valkyrie::ID) && !value.value.to_s.include?("://")
        end

        def result
          calling_mapper.for(Property.new(value.subject, value.key, value.adapter.id_to_uri(value.value), value.model_converter)).result
        end
      end

      class TimeValue < ::Valkyrie::ValueMapper
        FedoraValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.value.is_a?(Time)
        end

        def result
          calling_mapper.for(Property.new(value.subject, value.key, value.value.to_datetime, value.model_converter)).result
        end
      end

      class IdentifiableValue < ::Valkyrie::ValueMapper
        FedoraValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.value.is_a?(Valkyrie::ID)
        end

        def result
          calling_mapper.for(Property.new(value.subject, value.key, RDF::Literal.new(value.value, datatype: RDF::URI("http://example.com/predicate/valkyrie_id")), value.model_converter)).result
        end
      end

      class EnumerableValue < ::Valkyrie::ValueMapper
        FedoraValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.value.is_a?(Array)
        end

        def result
          new_values = value.value.map do |val|
            calling_mapper.for(Property.new(value.subject, value.key, val, value.model_converter)).result
          end
          CompositeProperty.new(new_values)
        end
      end
    end
  end
end
