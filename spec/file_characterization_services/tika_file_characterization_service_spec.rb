# frozen_string_literal: true

require 'rails_helper'
require 'valkyrie/specs/shared_specs'
include ActionDispatch::TestProcess

RSpec.describe TikaFileCharacterizationService do
  it_behaves_like 'a Valkyrie::FileCharacterizationService'
  let(:file_characterization_service) { described_class }
  let(:adapter) { Valkyrie::MetadataAdapter.find(:indexing_persister) }
  let(:storage_adapter) { Valkyrie.config.storage_adapter }
  let(:persister) { adapter.persister }
  let(:query_service) { adapter.query_service }
  let(:file) { fixture_file_upload('files/example.tif', 'image/tiff') }
  let(:change_set_persister) { ChangeSetPersister.new(metadata_adapter: adapter, storage_adapter: storage_adapter) }
  let(:book) do
    change_set_persister.save(change_set: BookChangeSet.new(Book.new, files: [file]))
  end
  let(:book_change_set) do
    BookChangeSet.new(Book.new).tap do |change_set|
      change_set.files = [file]
    end
  end
  let(:book_members) { query_service.find_members(resource: book) }
  let(:valid_file_set) { book_members.first }
  let(:valid_file) { Valkyrie::StorageAdapter.find_by(id: valid_file_set.file_identifiers.first) }
  before do
    output = '547c81b080eb2d7c09e363a670c46960ac15a6821033263867dd59a31376509c'
    ruby_mock = instance_double(Digest::SHA256, hexdigest: output)
    allow(Digest::SHA256).to receive(:hexdigest).and_return(ruby_mock)
  end

  it 'characterizes a sample file' do
    Valkyrie::FileCharacterizationService.for(file: valid_file, storage_adapter: storage_adapter).characterize

    file = Valkyrie::StorageAdapter.find_by(id: valid_file.id)
    resource = file.metadata_resource

    expect(resource.height).to eq [287]
    expect(resource.width).to eq [200]
    expect(resource.mime_type).to eq ["image/tiff"]
    expect(resource.label).to eq ["example.tif"]
    expect(resource.original_filename).to eq ["example.tif"]
    expect(resource.checksum).to eq ['547c81b080eb2d7c09e363a670c46960ac15a6821033263867dd59a31376509c']
    expect(resource.use).to eq [Valkyrie::Vocab::PCDMUse.OriginalFile]
  end
end
