# frozen_string_literal: true
require 'rails_helper'
require 'sleipnir/specs/shared_specs'

RSpec.describe CompositePersister do
  let(:persister) do
    described_class.new(
      Persister.new(
        adapter: Sleipnir::Persistence::Memory::Adapter.new
      ),
      Persister.new(
        adapter: Sleipnir::Persistence::Solr::Adapter.new(
          connection: Blacklight.default_index.connection
        )
      )
    )
  end
  it_behaves_like "a Sleipnir::Persister"
end
