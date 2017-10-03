# frozen_string_literal: true
module Valkyrie::Storage
  class Disk
    attr_reader :base_path, :path_generator, :file_mover
    def initialize(base_path:, path_generator: BucketedStorage, file_mover: FileUtils.method(:mv))
      @base_path = Pathname.new(base_path.to_s)
      @path_generator = path_generator.new(base_path: base_path)
      @file_mover = file_mover
    end

    # @param file [IO]
    # @param resource [Valkyrie::Resource]
    # @return [Valkyrie::StorageAdapter::File]
    def upload(file:, resource: nil)
      new_path = path_generator.generate(resource: resource, file: file)
      FileUtils.mkdir_p(new_path.parent)
      file_mover.call(file.path, new_path)
      find_by(id: Valkyrie::ID.new("disk://#{new_path}"))
    end

    # @param id [Valkyrie::ID]
    # @return [Boolean] true if this adapter can handle this type of identifer
    def handles?(id:)
      id.to_s.start_with?("disk://")
    end

    def file_path(id)
      id.to_s.gsub(/^disk:\/\//, '')
    end

    # Return the file associated with the given identifier
    # @param id [Valkyrie::ID]
    # @return [Valkyrie::StorageAdapter::File]
    # @return [nil] if nothing is found
    def find_by(id:)
      return unless handles?(id: id)
      Valkyrie::StorageAdapter::File.new(id: Valkyrie::ID.new(id.to_s), io: ::File.open(file_path(id), 'rb'))
    rescue Errno::ENOENT
      Valkyrie.logger.warn "File not found on disk for #{id}"
      nil
    end

    # Delete the file on disk associated with the given identifier.
    # @param id [Valkyrie::ID]
    def delete(id:)
      path = file_path(id)
      FileUtils.rm_rf(path) if File.exist?(path)
    end

    class BucketedStorage
      attr_reader :base_path
      def initialize(base_path:)
        @base_path = base_path
      end

      def generate(resource:, file:)
        Pathname.new(base_path).join(*bucketed_path(resource.id)).join(file.original_filename)
      end

      def bucketed_path(id)
        cleaned_id = id.to_s.delete("-")
        cleaned_id[0..5].chars.each_slice(2).map(&:join) + [cleaned_id]
      end
    end
  end
end
