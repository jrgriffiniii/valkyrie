# frozen_string_literal: true

# Class for Apache Tika based file characterization service
# defines the Apache Tika based characterization service a ValkyrieFileCharacterization service
# @since 0.1.0
class TikaFileCharacterizationService
  attr_reader :file, :storage_adapter
  def initialize(file:, storage_adapter:)
    @file = file
    @storage_adapter = storage_adapter
  end

  # characterizes the file passed into this service
  # @return [FileNode]
  # @example characterize a file and persist the changes
  #   Valkyrie::FileCharacterizationService.for(file, storage_adapter).characterize
  def characterize
    result = JSON.parse(json_output).last
    file_characterization_attributes = FileCharacterizationAttributes.new(old_resource.to_h.except(:internal_resource).merge(
                                                                            width: result['tiff:ImageWidth'],
                                                                            height: result['tiff:ImageLength'],
                                                                            mime_type: result['Content-Type'],
                                                                            checksum: checksum
    ))
    storage_adapter.update_metadata(file: file, metadata_resource: file_characterization_attributes)
    file.metadata_resource = file_characterization_attributes
    file
  end

  def old_resource
    file.metadata_resource || FileCharacterizationAttributes.new
  end

  # Provides the SHA256 hexdigest string for the file
  # @return String
  def checksum
    Digest::SHA256.file(filename).hexdigest
  end

  def json_output
    "[#{RubyTikaApp.new(filename.to_s).to_json.gsub('}{', '},{')}]"
  end

  # Determines the location of the file on disk for the file
  # @return Pathname
  def filename
    return Pathname.new(file.io.path) if file.io.respond_to?(:path) && File.exist?(file.io.path)
  end

  def valid?
    true
  end

  # Class for updating characterization attributes on the FileNode
  class FileCharacterizationAttributes < Valkyrie::Resource
    attribute :width, Valkyrie::Types::Set.member(Valkyrie::Types::Coercible::Int)
    attribute :height, Valkyrie::Types::Set.member(Valkyrie::Types::Coercible::Int)
    attribute :mime_type, Valkyrie::Types::Set
    attribute :label, Valkyrie::Types::Set
    attribute :original_filename, Valkyrie::Types::Set
    attribute :use, Valkyrie::Types::Set
    attribute :checksum, Valkyrie::Types::Set
  end
end
