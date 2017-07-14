# frozen_string_literal: true
module Valkyrie::Storage
  class Disk
    class FileNode < Valkyrie::Resource
      attribute :id, Valkyrie::Types::ID.optional
      attribute :path, Valkyrie::Types::SingleValuedString
      attribute :metadata_resource, Valkyrie::Types::Anything
    end
    attr_reader :base_path, :metadata_adapter
    delegate :persister, :query_service, to: :metadata_adapter
    def initialize(base_path:, metadata_adapter:)
      @base_path = Pathname.new(base_path.to_s)
      @metadata_adapter = metadata_adapter
    end

    # @param file [IO]
    # @param resource [Valkyrie::Resource]
    # @return [Valkyrie::StorageAdapter::File]
    def upload(file:, resource: nil, metadata_resource: nil)
      new_path = base_path.join(resource.try(:id).to_s, file.original_filename)
      FileUtils.mkdir_p(new_path.parent)
      FileUtils.mv(file.path, new_path)
      file_node = persister.save(resource: FileNode.new(path: new_path, metadata_resource: metadata_resource))
      find_by(id: Valkyrie::ID.new("disk://#{file_node.id}"))
    end

    def update_metadata(file:, metadata_resource:)
      file_node = find_node(id: file.id)
      file_node.metadata_resource = metadata_resource
      persister.save(resource: file_node)
      file.metadata_resource = metadata_resource
      file
    end

    # @param id [Valkyrie::ID]
    # @return [Boolean] true if this adapter can handle this type of identifer
    def handles?(id:)
      id.to_s.start_with?("disk://")
    end

    # Return the file associated with the given identifier
    # @param id [Valkyrie::ID]
    # @return [Valkyrie::StorageAdapter::File]
    def find_by(id:)
      return unless handles?(id: id)
      file_node = find_node(id: id)
      Valkyrie::StorageAdapter::File.new(id: Valkyrie::ID.new(id.to_s), io: ::File.open(file_node.path), metadata_resource: file_node.metadata_resource)
    end

    private

      def find_node(id:)
        query_service.find_by(id: node_id(id: id))
      end

      def node_id(id:)
        Valkyrie::ID.new(id.to_s.gsub(/^disk:\/\//, ''))
      end
  end
end
