# frozen_string_literal: true
require 'rails_helper'
require 'sleipnir/specs/shared_specs'

RSpec.describe AppendingPersister do
  let(:persister) { described_class.new(Persister.new(adapter: Sleipnir::Persistence::Memory::Adapter.new)) }
  it_behaves_like "a Sleipnir::Persister"

  it "appends when given a form with an append_id" do
    parent = persister.save(model: Book.new)
    form = BookForm.new(Book.new)
    form.append_id = parent.id

    output = persister.save(model: form)
    reloaded = persister.adapter.query_service.find_by(id: parent.id)

    expect(reloaded.member_ids).to eq [output.id]
  end
end
