# frozen_string_literal: true
require 'rails_helper'
require 'sleipnir/specs/shared_specs'

RSpec.describe Sleipnir::Adapter do
  described_class.adapters.each do |_key, adapter|
    let(:adapter) { adapter }
    it_behaves_like "a Sleipnir::Adapter", adapter
  end
end
