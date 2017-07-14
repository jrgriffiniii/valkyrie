# frozen_string_literal: true
module Valkyrie::Storage
  require 'hydra/works'
  class Fedora
    class ValkyrieModelSchema < ActiveTriples::Schema
      property :internal_resource, predicate: ::RDF::URI("http://example.com/internal_resource"), multiple: false
      property :original_filename, predicate: ::RDF::URI("http://example.com/original_filename"), multiple: false
      property :use, predicate: ::RDF::URI("http://example.com/use")
    end
    class File < Hydra::PCDM::File
      def metadata_node_attributes
        metadata_node.attributes.tap do |output|
          output['internal_resource'] = Array(output['internal_resource']).first
        end
      end
    end
    ActiveFedora::WithMetadata::DefaultMetadataClassFactory.file_metadata_schemas +=
      [
        Valkyrie::Storage::Fedora::ValkyrieModelSchema
      ]
    attr_reader :connection
    PROTOCOL = 'fedora://'
    def initialize(connection:)
      @connection = connection
    end

    # @param id [Valkyrie::ID]
    # @return [Boolean] true if this adapter can handle this type of identifer
    def handles?(id:)
      id.to_s.start_with?(PROTOCOL)
    end

    # Return the file associated with the given identifier
    # @param id [Valkyrie::ID]
    # @return [Valkyrie::StorageAdapter::File]
    def find_by(id:)
      file = af_file(id: id)
      Valkyrie::StorageAdapter::File.new(id: id, io: response(af_file: file), metadata_resource: metadata(af_file: file))
    end

    # @param file [IO]
    # @param resource [Valkyrie::Resource]
    # @return [Valkyrie::StorageAdapter::File]
    def upload(file:, resource:, metadata_resource: nil)
      # TODO: this is a very naive aproach. Change to PCDM
      identifier = resource.id.to_uri + '/original'
      File.new(identifier) do |af|
        af.content = file
        af.save!
        af.metadata_node.set_value(:type, af.metadata_node.type + [::RDF::URI('http://pcdm.org/use#OriginalFile')])
        af.metadata_node.attributes = metadata_resource.attributes.select { |_x, y| y.present? } if metadata_resource
        af.metadata_node.save
      end
      find_by(id: Valkyrie::ID.new(identifier.to_s.sub(/^.+\/\//, PROTOCOL)))
    end

    def update_metadata(file:, metadata_resource:)
      af = af_file(id: file.id)
      af.metadata_node.attributes = Hash[af.metadata_node.attributes.map { |k, _v| [k, nil] }].select { |k, _v| !k.start_with?("http") && k != "file_hash" }
      af.metadata_node.attributes = metadata_resource.attributes.select { |_x, y| y.present? } if metadata_resource
      af.metadata_node.save
      file.new(metadata_resource: metadata_resource)
    end

    class IOProxy
      # @param response [Ldp::Resource::BinarySource]
      def initialize(source)
        @source = source
      end
      delegate :read, to: :io

      # There is no streaming support in faraday (https://github.com/lostisland/faraday/pull/604)
      # @return [StringIO]
      def io
        @io ||= StringIO.new(@source.get.response.body)
      end
    end
    private_constant :IOProxy

    private

      # @return [IOProxy]
      def response(af_file:)
        IOProxy.new(af_file.ldp_source)
      end

      def af_file(id:)
        File.new(active_fedora_identifier(id: id))
      end

      # Translate the Valkrie ID into a URL for the fedora file
      # @return [RDF::URI]
      def active_fedora_identifier(id:)
        scheme = URI(ActiveFedora.config.credentials[:url]).scheme
        identifier = id.to_s.sub(PROTOCOL, "#{scheme}://")
        RDF::URI(identifier)
      end

      def metadata(af_file:)
        return nil unless af_file.metadata_node_attributes['internal_resource']
        Valkyrie::Types::Anything[af_file.metadata_node_attributes.select { |_k, v| v.present? }.symbolize_keys]
      end
  end
end
