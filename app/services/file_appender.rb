# frozen_string_literal: true
class FileAppender
  class MetadataResource < Valkyrie::Resource
    attribute :label, Valkyrie::Types::Set
    attribute :original_filename, Valkyrie::Types::Set
    attribute :mime_type, Valkyrie::Types::Set
    attribute :use, Valkyrie::Types::Set
  end
  attr_reader :storage_adapter, :persister, :files
  def initialize(storage_adapter:, persister:, files:)
    @storage_adapter = storage_adapter
    @persister = persister
    @files = files
  end

  def append_to(resource)
    return resource if files.blank?
    return append_files(resource: resource) if appending_derivative?
    file_sets = build_file_sets
    resource.member_ids = resource.member_ids + file_sets.map(&:id)
    persister.save(resource: resource)
  end

  def build_file_sets
    files.map do |file|
      file_set = create_file_set(file)
      file_set = append_file(file: file, resource: file_set)
      Valkyrie::DerivativeService.for(FileSetChangeSet.new(file_set)).create_derivatives
      file_set
    end
  end

  def metadata(file:)
    MetadataResource.new(
      label: file.original_filename, original_filename: file.original_filename, mime_type: file.content_type, use: file.try(:use) || Valkyrie::Vocab::PCDMUse.OriginalFile
    )
  end

  def characterization_data(file:)
    Valkyrie::FileCharacterizationService.for(file: file, storage_adapter: storage_adapter).characterize
  end

  def append_files(resource:)
    files.map do |file|
      append_file(file: file, resource: resource)
    end
  end

  def append_file(file:, resource:)
    uploaded_file = uploaded_file(file: file, resource: resource)
    uploaded_file = characterization_data(file: uploaded_file)
    resource.file_identifiers = resource.file_identifiers + [uploaded_file.id]
    persister.save(resource: resource)
  end

  def uploaded_file(file:, resource:)
    storage_adapter.upload(file: file, resource: resource, metadata_resource: metadata(file: file))
  end

  def create_file_set(file)
    persister.save(resource: FileSet.new(title: file.original_filename))
  end

  def appending_derivative?
    files.find do |file|
      metadata(file: file).use.include?(Valkyrie::Vocab::PCDMUse.ServiceFile)
    end.present?
  end
end
