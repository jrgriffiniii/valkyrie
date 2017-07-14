# frozen_string_literal: true
module Valkyrie::Storage
  class Memory
    attr_reader :cache
    def initialize
      @cache = {}
    end

    # @param file [IO]
    # @param resource [Valkyrie::Resource]
    # @return [Valkyrie::StorageAdapter::File]
    def upload(file:, resource: nil, metadata_resource: nil)
      identifier = Valkyrie::ID.new("memory://#{resource.id}/#{file.original_filename}")
      cache[identifier] = Valkyrie::StorageAdapter::File.new(id: identifier, io: file, metadata_resource: metadata_resource)
    end

    def update_metadata(file:, metadata_resource:)
      file.metadata_resource = metadata_resource
      cache[file.id] = file
    end

    # Return the file associated with the given identifier
    # @param id [Valkyrie::ID]
    # @return [Valkyrie::StorageAdapter::File]
    def find_by(id:)
      return unless handles?(id: id) && cache[id]
      cache[id]
    end

    # @param id [Valkyrie::ID]
    # @return [Boolean] true if this adapter can handle this type of identifer
    def handles?(id:)
      id.to_s.start_with?("memory://")
    end
  end
end
