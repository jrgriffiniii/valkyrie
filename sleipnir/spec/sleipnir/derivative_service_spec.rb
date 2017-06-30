# frozen_string_literal: true
require 'spec_helper'
require 'sleipnir/specs/shared_specs'

RSpec.describe Sleipnir::DerivativeService do
  it_behaves_like "a Sleipnir::DerivativeService"
  let(:valid_file_set) { FileSet.new }
  let(:derivative_service) { described_class }
  before do
    class FileSet < Sleipnir::Model
      attribute :id, Sleipnir::Types::ID.optional
      attribute :title, Sleipnir::Types::Set
      attribute :file_identifiers, Sleipnir::Types::Set
      attribute :member_ids, Sleipnir::Types::Array
    end
  end
  after do
    Object.send(:remove_const, :FileSet)
  end

  it "can have a registered service" do
    new_service = instance_double(described_class, valid?: true)
    service_class = class_double(described_class, new: new_service)
    described_class.services << service_class
    expect(described_class.for(valid_file_set)).to eq new_service
  end
end
