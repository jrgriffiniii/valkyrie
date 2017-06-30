# frozen_string_literal: true
require 'rails_helper'
require 'sleipnir/specs/shared_specs'

RSpec.describe ParentCleanupPersister do
  let(:persister) { described_class.new(Persister.new(adapter: Sleipnir::Persistence::Memory::Adapter.new)) }
  it_behaves_like "a Sleipnir::Persister"

  it "cleans up children's parents on delete" do
    child = persister.save(model: Book.new)
    parent = persister.save(model: Book.new(member_ids: [child.id]))

    persister.delete(model: child)
    reloaded = persister.adapter.query_service.find_by(id: parent.id)

    expect(reloaded.member_ids).to eq []
  end
end
