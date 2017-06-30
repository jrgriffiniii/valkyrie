# frozen_string_literal: true
require 'sleipnir'
Rails.application.config.to_prepare do
  Sleipnir::Adapter.register(
    Sleipnir::Persistence::Postgres::Adapter,
    :postgres
  )

  Sleipnir::Adapter.register(
    Valkyrie::Persistence::ActiveFedora::Adapter,
    :fedora
  )

  Sleipnir::Adapter.register(
    Sleipnir::Persistence::Memory::Adapter.new,
    :memory
  )

  Sleipnir::Adapter.register(
    Sleipnir::Persistence::Solr::Adapter.new(connection: Blacklight.default_index.connection,
                                             resource_indexer: Sleipnir::Indexers::AccessControlsIndexer),
    :index_solr
  )

  Sleipnir::FileRepository.register(
    Sleipnir::FileRepository::DiskRepository.new(base_path: Rails.root.join("tmp", "repo")),
    :disk
  )

  Sleipnir::FileRepository.register(
    Sleipnir::FileRepository::Memory.new,
    :memory
  )

  persister_list = Sleipnir::Decorators::DecoratorList.new(
    Sleipnir::Decorators::DecoratorWithArguments.new(FileSetAppendingPersister,
                                                     repository: Sleipnir.config.storage_adapter,
                                                     node_factory: FileNode,
                                                     file_container_factory: FileSet),
    ParentCleanupPersister,
    AppendingPersister
  )

  Sleipnir::Adapter.register(
    Sleipnir::AdapterContainer.new(persister: persister_list.new(
      CompositePersister.new(
        Sleipnir.config.adapter.persister,
        Sleipnir::Adapter.find(:index_solr).persister
      )
    ),
                                   query_service: Sleipnir.config.adapter.query_service),
    :indexing_persister
  )

  Sleipnir::DerivativeService.services << ImageDerivativeService::Factory.new(
    adapter: Sleipnir::Adapter.find(:indexing_persister),
    storage_adapter: Sleipnir.config.storage_adapter,
    use: [Sleipnir::Vocab::PCDMUse.ThumbnailImage]
  )
end
