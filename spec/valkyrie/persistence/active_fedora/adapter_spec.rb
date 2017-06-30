# frozen_string_literal: true
require 'rails_helper'
require 'sleipnir/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::ActiveFedora::Adapter do
  let(:adapter) { described_class }
  it_behaves_like "a Sleipnir::Adapter"
end
