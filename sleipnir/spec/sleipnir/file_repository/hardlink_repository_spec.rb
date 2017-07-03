# frozen_string_literal: true
require 'spec_helper'
require 'sleipnir/specs/shared_specs'
include ActionDispatch::TestProcess

RSpec.describe Sleipnir::FileRepository::HardlinkRepository do
  it_behaves_like "a Sleipnir::StorageAdapter"
  let(:storage_adapter) { described_class.new(base_path: ROOT_PATH.join("tmp", "repo_test")) }
  let(:file) { fixture_file_upload('files/example.tif', 'image/tiff') }
  before do
    class Resource < Sleipnir::Model
      attribute :id, Sleipnir::Types::ID.optional
    end
  end
  after do
    Object.send(:remove_const, :Resource)
  end
  it "creates a bucketed hard link (both have same inode number)" do
    stored_file = storage_adapter.upload(file: file, model: Resource.new(id: "testi-ngthis"))

    expect(File.stat(stored_file.io.path).ino).to eq File.stat(file.path).ino
    expect(stored_file.io.path).to eq ROOT_PATH.join("tmp", "repo_test", "te", "st", "in", "testingthis", "example.tif").to_s
  end
  context "when passed an ID generator" do
    let(:storage_adapter) { described_class.new(base_path: ROOT_PATH.join("tmp", "repo_test"), path_generator: Sleipnir::FileRepository::HardlinkRepository::ContentAddressablePath) }
    it "uses it" do
      stored_file = storage_adapter.upload(file: file, model: Resource.new(id: "test"))

      expect(stored_file.io.path).to eq ROOT_PATH.join("tmp", "repo_test", "083f", "af23", "6c9c", "083faf236c9c79ab24ebc61fa60a02e5d2bfc9cc8a0944dac57ce2b6765deff3.tif").to_s
    end
  end
end
