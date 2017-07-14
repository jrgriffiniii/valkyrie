# frozen_string_literal: true
require 'rails_helper'

RSpec.describe DownloadsController do
  let(:user) { FactoryGirl.create(:admin) }
  before do
    sign_in user if user
  end
  let(:file) { fixture_file_upload('files/example.tif', 'image/tiff') }
  let(:change_set_persister) { ChangeSetPersister.new(metadata_adapter: Valkyrie.config.metadata_adapter, storage_adapter: Valkyrie.config.storage_adapter) }
  let(:change_set) { PageChangeSet.new(Page.new, files: [file]) }
  let(:resource) { change_set_persister.save(change_set: change_set) }
  let(:uploaded_file) { Valkyrie::StorageAdapter.find_by(id: file_set.file_identifiers.first) }
  let(:file_set) { Valkyrie.config.metadata_adapter.query_service.find_members(resource: resource).first }

  describe "GET /downloads/:id" do
    context "when there's a FileSet with that ID" do
      it "returns it" do
        get :show, params: { id: file_set.id.to_s }

        uploaded_file.rewind

        expect(response.body).to eq uploaded_file.read
        headers = response.headers
        expect(headers['Content-Type']).to eq "image/tiff"
        expect(headers["Content-Disposition"]).to eq "inline; filename=\"example.tif\""
      end
    end
  end
end
