# frozen_string_literal: true

class ImageDerivativeService
  class Factory
    attr_reader :change_set_persister, :image_config, :use
    delegate :metadata_adapter, :storage_adapter, to: :change_set_persister
    def initialize(change_set_persister:, image_config: ImageConfig.new(width: 200, height: 150, format: 'jpg', mime_type: 'image/jpeg', output_name: 'thumbnail'), use: [])
      @change_set_persister = change_set_persister
      @image_config = image_config
      self.use = use
    end

    def use=(use)
      @use = Array(use) + [Valkyrie::Vocab::PCDMUse.ServiceFile]
    end

    def new(change_set)
      ::ImageDerivativeService.new(change_set: change_set, original_file: original_file(change_set), change_set_persister: change_set_persister, image_config: image_config, use: use)
    end

    def original_file(model)
      files(model).find { |x| x.metadata_resource.use.include?(Valkyrie::Vocab::PCDMUse.OriginalFile) }
    end

    def files(model)
      model.file_identifiers.map do |id|
        Valkyrie::StorageAdapter.find_by(id: id)
      end
    end

    class ImageConfig < Dry::Struct
      attribute :width, Valkyrie::Types::Int
      attribute :height, Valkyrie::Types::Int
      attribute :format, Valkyrie::Types::String
      attribute :mime_type, Valkyrie::Types::String
      attribute :output_name, Valkyrie::Types::String
    end
  end
  attr_reader :change_set, :original_file, :image_config, :use, :change_set_persister
  delegate :metadata_adapter, :storage_adapter, to: :change_set_persister
  delegate :width, :height, :format, :output_name, to: :image_config
  delegate :persister, to: :metadata_adapter
  def initialize(change_set:, original_file:, change_set_persister:, image_config:, use:)
    @change_set = change_set
    @original_file = original_file
    @change_set_persister = change_set_persister
    @image_config = image_config
    @use = use
  end

  def image_mime_type
    image_config.mime_type
  end

  def mime_type
    original_file.metadata_resource.mime_type
  end

  def create_derivatives
    Hydra::Derivatives::ImageDerivatives.create(filename,
                                                outputs: [{ label: :thumbnail, format: format, size: "#{width}x#{height}>", url: URI("file://#{temporary_output.path}") }])
    change_set.files = [build_file]
    change_set_persister.save(change_set: change_set)
  end

  class IoDecorator < SimpleDelegator
    attr_reader :original_filename, :content_type, :use
    def initialize(io, original_filename, content_type, use)
      @original_filename = original_filename
      @content_type = content_type
      @use = use
      super(io)
    end
  end

  def build_file
    IoDecorator.new(temporary_output, "#{output_name}.#{format}", mime_type, use)
  end

  def cleanup_derivatives; end

  def filename
    return Pathname.new(original_file.io.path) if original_file.io.respond_to?(:path) && File.exist?(original_file.io.path)
  end

  def temporary_output
    @temporary_file ||= Tempfile.new
  end

  ALLOWABLE_FORMATS = [
    'image/bmp',
    'image/gif',
    'image/jpeg',
    'image/png',
    'image/tiff'
  ].freeze

  def valid?
    ALLOWABLE_FORMATS.include?(mime_type.first)
  end
end
