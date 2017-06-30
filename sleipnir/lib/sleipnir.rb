# frozen_string_literal: true
require "sleipnir/version"
require "ostruct"
require 'active_support'
require 'active_support/core_ext'
require 'dry-types'
require 'dry-struct'
require 'draper'
require 'active_record'
require 'reform'
require 'reform/active_record'
require 'rdf'
require 'sleipnir/rdf_patches'
require 'json/ld'
require 'logger'
require 'active_triples'
require 'rdf/vocab'
require 'active_fedora'
require 'hydra-access-controls'

# frozen_string_literal: true
module Sleipnir
  require 'sleipnir/id'
  require 'sleipnir/form'
  require 'sleipnir/value_mapper'
  require 'sleipnir/persistence'
  require 'sleipnir/types'
  require 'sleipnir/model'
  require 'sleipnir/derivative_service'
  require 'sleipnir/file_repository'
  require 'sleipnir/adapter'
  require 'sleipnir/adapter_container'
  require 'sleipnir/decorators/decorator_list'
  require 'sleipnir/decorators/decorator_with_arguments'
  require 'sleipnir/model/access_controls'
  require 'sleipnir/indexers/access_controls_indexer'
  require 'sleipnir/vocab/pcdm_use'
  def config
    Config.new(
      YAML.safe_load(ERB.new(File.read(config_root_path.join("config", "sleipnir.yml"))).result)[Rails.env]
    )
  end

  def config_root_path
    if const_defined?(:Rails) && Rails.root
      Rails.root
    else
      Pathname.new(Dir.pwd)
    end
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end

  def logger=(logger)
    @logger = logger
  end

  class Config < OpenStruct
    def adapter
      Sleipnir::Adapter.find(super.to_sym)
    end

    def storage_adapter
      Sleipnir::FileRepository.find(super.to_sym)
    end
  end

  module_function :config, :logger, :logger=, :config_root_path
end
