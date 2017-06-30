# frozen_string_literal: true
require 'hydra/derivatives'
module Sleipnir
  class DerivativeService
    require 'sleipnir/local_file_service'
    require 'sleipnir/persist_derivatives'
    Hydra::Derivatives.source_file_service = Sleipnir::LocalFileService
    Hydra::Derivatives.output_file_service = Sleipnir::PersistDerivatives
    class_attribute :services
    self.services = []
    def self.for(file_set)
      services.map { |service| service.new(file_set) }.find(&:valid?) ||
        new(file_set)
    end
    attr_reader :file_set
    delegate :mime_type, :uri, to: :file_set
    def initialize(file_set)
      @file_set = file_set
    end

    def cleanup_derivatives; end

    def create_derivatives; end

    def valid?
      true
    end
  end
end
