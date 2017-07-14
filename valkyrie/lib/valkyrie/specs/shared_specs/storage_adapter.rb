# frozen_string_literal: true
RSpec.shared_examples 'a Valkyrie::StorageAdapter' do
  before do
    raise 'storage_adapter must be set with `let(:storage_adapter)`' unless
      defined? storage_adapter
    raise 'file must be set with `let(:file)`' unless
      defined? file
    class CustomResource < Valkyrie::Resource
      attribute :id, Valkyrie::Types::ID.optional
    end
    class CustomMetadataResource < Valkyrie::Resource
      attribute :width, Valkyrie::Types::Set
    end
  end
  after do
    Object.send(:remove_const, :CustomResource)
    Object.send(:remove_const, :CustomMetadataResource)
  end
  subject { storage_adapter }
  it { is_expected.to respond_to(:handles?).with_keywords(:id) }
  it { is_expected.to respond_to(:find_by).with_keywords(:id) }
  it { is_expected.to respond_to(:upload).with_keywords(:file, :resource, :metadata_resource) }

  it "can upload and re-fetch a file" do
    resource = CustomResource.new(id: SecureRandom.uuid)
    expect(uploaded_file = storage_adapter.upload(file: file, resource: resource, metadata_resource: CustomMetadataResource.new(width: 100))).to be_kind_of Valkyrie::StorageAdapter::File
    expect(storage_adapter.handles?(id: uploaded_file.id)).to eq true
    file = storage_adapter.find_by(id: uploaded_file.id)
    expect(file.id).to eq uploaded_file.id
    expect(file).to respond_to(:stream).with(0).arguments
    expect(file).to respond_to(:read).with(0).arguments
    expect(file).to respond_to(:rewind).with(0).arguments
    expect(file.stream).to respond_to(:read)
    expect(file.metadata_resource.width).to eq [100]
    new_file = Tempfile.new
    expect { IO.copy_stream(file, new_file) }.not_to raise_error
  end

  it "shouldn't require a metadata resource" do
    resource = CustomResource.new(id: SecureRandom.uuid)
    expect(storage_adapter.upload(file: file, resource: resource)).to be_kind_of Valkyrie::StorageAdapter::File
  end

  it "can update the metadata" do
    resource = CustomResource.new(id: SecureRandom.uuid)
    uploaded_file = storage_adapter.upload(file: file, resource: resource, metadata_resource: CustomMetadataResource.new(width: 100))

    storage_adapter.update_metadata(file: uploaded_file, metadata_resource: uploaded_file.metadata_resource.new(width: 50))
    file = storage_adapter.find_by(id: uploaded_file.id)

    expect(file.metadata_resource.width).to eq [50]
    storage_adapter.update_metadata(file: uploaded_file, metadata_resource: nil)
    file = storage_adapter.find_by(id: uploaded_file.id)
    expect(file.metadata_resource).to be_nil
  end
end
