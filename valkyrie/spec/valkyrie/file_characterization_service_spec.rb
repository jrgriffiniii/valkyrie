# frozen_string_literal: true

require 'spec_helper'
require 'valkyrie/specs/shared_specs'
include ActionDispatch::TestProcess

RSpec.describe Valkyrie::FileCharacterizationService do
  it_behaves_like "a Valkyrie::FileCharacterizationService"
  let(:storage_adapter) { Valkyrie::Storage::Memory.new }
  let(:valid_file) { storage_adapter.upload(resource: model, file: file_to_upload) }
  let(:klass) do
    Class.new(Valkyrie::Resource).tap do |k|
      k.attribute :id, Valkyrie::Types::ID.optional
    end
  end
  let(:model) { klass.new(id: SecureRandom.uuid) }
  let(:file_to_upload) { fixture_file_upload('files/example.tif', 'image/tiff') }
  let(:file_characterization_service) { described_class }

  it 'can have a registered service' do
    new_service = instance_double(described_class, valid?: true)
    service_class = class_double(described_class, new: new_service)
    described_class.services << service_class
    expect(described_class.for(file: valid_file, storage_adapter: storage_adapter)).to eq new_service
  end
end
