# frozen_string_literal: true
class IngestMETSJob < ApplicationJob
  queue_as :ingest
  attr_reader :mets

  # @param [String] mets_file Filename of a METS file to ingest
  # @param [String] user User to ingest as
  def perform(mets_file, user)
    logger.info "Ingesting METS #{mets_file}"
    @mets = METSDocument::Factory.new(mets_file).new
    @user = user
    Valkyrie::Persistence::Postgres::ORM::Resource.transaction do
      ingester = Ingester.for(mets: @mets, user: @user, adapter: adapter)
      ingester.ingest
      solr_adapter.persister.save_all(models: memory_adapter.query_service.find_all.to_a)
      puts "Total ingested resources: #{memory_adapter.query_service.find_all.to_a.length}"
    end
  end

  def solr_adapter
    Valkyrie::Adapter.find(:index_solr)
  end

  def adapter
    @adapter ||= Valkyrie::AdapterContainer.new(
      persister: CompositePersister.new(Valkyrie::Adapter.find(:indexing_persister).persister, memory_adapter.persister),
      query_service: Valkyrie::Adapter.find(:indexing_persister).query_service
    )
  end

  def memory_adapter
    @memory_adapter ||= Valkyrie::Persistence::Memory::Adapter.new
  end

  class Ingester
    delegate :persister, :query_service, to: :adapter
    def self.for(mets:, user:, adapter:)
      if mets.multi_volume?
        MVWIngester.new(mets: mets, user: user, adapter: adapter)
      else
        new(mets: mets, user: user, adapter: adapter)
      end
    end

    attr_reader :mets, :user, :adapter
    def initialize(mets:, user:, adapter:)
      @mets = mets
      @user = user
      @adapter = adapter
    end

    def ingest
      resource.source_metadata_identifier = mets.bib_id
      files.each do |file|
        appender.append(file)
        mets_to_repo_map[file.id] = resource.member_ids.last
        file.close
      end
      resource.structure = [{ label: "Main Structure", nodes: map_fileids(mets.structure)[:nodes] }]
      resource.sync
      persister.save(model: resource)
    end

    def files
      mets.files.lazy.map do |file|
        mets.decorated_file(file)
      end
    end

    def appender
      @appender ||= FileSetAppendingPersister::Appender.new(model: resource, persister: persister, repository: repository, node_factory: FileNode, file_container_factory: FileSet)
    end

    def resource
      @resource ||=
        begin
          BookForm.new(Book.new)
        end
    end

    def repository
      Valkyrie.config.storage_adapter
    end

    def map_fileids(hsh)
      hsh.each do |k, v|
        hsh[k] = v.each { |node| map_fileids(node) } if k == :nodes
        hsh[k] = mets_to_repo_map[v] if k == :proxy
      end
    end

    def mets_to_repo_map
      @mets_to_repo_map ||= {}
    end
  end

  class MVWIngester < Ingester
    def ingest
      resource.source_metadata_identifier = mets.bib_id
      mets.volume_ids.each do |volume_id|
        volume_mets = VolumeMets.new(parent_mets: mets, volume_id: volume_id)
        volume = Ingester.new(mets: volume_mets, user: user, adapter: adapter).ingest
        resource.member_ids = resource.member_ids + [volume.id]
      end
      persister.save(model: resource)
    end
  end

  class VolumeMets
    attr_reader :parent_mets, :volume_id
    delegate :decorated_file, to: :parent_mets
    def initialize(parent_mets:, volume_id:)
      @parent_mets = parent_mets
      @volume_id = volume_id
    end

    def bib_id
      nil
    end

    def files
      parent_mets.files_for_volume(volume_id)
    end

    def structure
      parent_mets.structure_for_volume(volume_id)
    end
  end
end
