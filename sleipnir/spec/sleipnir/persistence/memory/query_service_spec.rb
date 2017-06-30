# frozen_string_literal: true
require 'spec_helper'
require 'sleipnir/specs/shared_specs'

RSpec.describe Sleipnir::Persistence::Memory::QueryService do
  let(:adapter) { Sleipnir::Persistence::Memory::Adapter.new }
  it_behaves_like "a Sleipnir query provider"
end
