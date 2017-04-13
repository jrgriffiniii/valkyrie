# frozen_string_literal: true
require 'valkyrie/active_model'
Rails.application.config.to_prepare do
  Valkyrie::Adapter.register(
    Valkyrie::Persistence::Postgres,
    :postgres
  )

  Valkyrie::Adapter.register(
    Valkyrie::Persistence::Fedora,
    :fedora
  )

  Valkyrie::Adapter.register(
    Valkyrie::Persistence::Memory::Adapter.new,
    :memory
  )

  Valkyrie::Adapter.register(
    Valkyrie::Persistence::Solr::Adapter.new(connection: Blacklight.default_index.connection),
    :index_solr
  )

  business_logic_persister = BusinessLogicPersister.new(
    ParentCleanupPersister,
    AppendingPersister
  )

  Valkyrie::Adapter.register(
    AdapterContainer.new(
      persister:
        business_logic_persister.new(
          CompositePersister.new(
            Valkyrie.config.adapter.persister,
            Valkyrie::Adapter.find(:index_solr).persister
          )
        ),
      query_service: Valkyrie.config.adapter.query_service
    ),
    :indexing_persister
  )
end

class BusinessLogicPersister
  attr_reader :persisters
  def initialize(*persisters)
    @persisters = persisters
  end

  def new(persister)
    persisters.each do |p|
      persister = p.new(persister)
    end
    persister
  end
end
