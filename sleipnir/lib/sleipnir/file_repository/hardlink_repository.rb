# frozen_string_literal: true
module Sleipnir
  class FileRepository
    class HardlinkRepository
      attr_reader :base_path, :path_generator
      def initialize(base_path:, path_generator: BucketedStorage)
        @base_path = base_path
        @path_generator = path_generator.new(base_path: base_path)
      end

      def upload(file:, model: nil)
        new_path = path_generator.generate(model: model, file: file)
        FileUtils.mkdir_p(new_path.parent)
        FileUtils.ln(file.path, new_path, force: true)
        find_by(id: Sleipnir::ID.new("hardlink://#{new_path}"))
      end

      def find_by(id:)
        return unless handles?(id: id)
        ::Sleipnir::FileRepository::File.new(id: Sleipnir::ID.new(id.to_s), io: ::File.open(file_path(id)))
      end

      def file_path(id)
        id.to_s.gsub(/^hardlink:\/\//, '')
      end

      def handles?(id:)
        id.to_s.start_with?("hardlink://#{base_path}")
      end

      class BucketedStorage
        attr_reader :base_path
        def initialize(base_path:)
          @base_path = base_path
        end

        def generate(file:, model:)
          Pathname.new(base_path).join(*bucketed_path(model.id)).join(file.original_filename)
        end

        def bucketed_path(id)
          cleaned_id = id.to_s.delete("-")
          cleaned_id[0..5].chars.each_slice(2).map(&:join) + [cleaned_id]
        end
      end

      class ContentAddressablePath
        attr_reader :base_path
        def initialize(base_path:)
          @base_path = base_path
        end

        def generate(file:, model:)
          sha = sha(file).to_s
          Pathname.new(base_path).join(*bucketed_path(sha)).join("#{sha}#{file.original_filename.gsub(/^.*\./, '.')}")
        end

        def sha(file)
          Digest::SHA256.file(file.path)
        end

        def bucketed_path(sha)
          sha[0..11].chars.each_slice(4).map(&:join)
        end
      end
    end
  end
end
