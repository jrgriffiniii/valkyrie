# frozen_string_literal: true
require 'ruby_tika_app'

module Valkyrie
  # Abstract base class for file characterization
  # registers file characterization service a ValkyrieFileCharacterization service
  # initializes the interface for file characterization
  # @since 0.1.0
  class FileCharacterizationService
    class_attribute :services
    self.services = []
    # initializes the file characterization service
    # @param file_node [FileNode] the FileNode to be characterized
    # @param persister [AppendingPersister] the Persister used to save the FileNode
    # @return [TikaFileCharacterizationService] the file characterization service, currently only TikaFileCharacterizationService is implemented
    def self.for(file:, storage_adapter:)
      services.map { |service| service.new(file: file, storage_adapter: storage_adapter) }.find(&:valid?) ||
        new(file: file, storage_adapter: storage_adapter)
    end
    attr_reader :file, :storage_adapter
    delegate :mime_type, :height, :width, to: :file_node
    def initialize(file:, storage_adapter:)
      @file = file
      @storage_adapter = storage_adapter
    end

    # characterizes the file_node passed into this service
    # Default options are:
    #   save: true
    # @param save [Boolean] should the persister save the file_node after Characterization
    # @return [FileNode]
    def characterize
      file
    end

    # Stub function that sets this service as valid for all FileNode types
    def valid?
      true
    end
  end
end
