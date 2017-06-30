# frozen_string_literal: true
require 'spec_helper'
require 'sleipnir/specs/shared_specs'

RSpec.describe Sleipnir::Persistence::Memory::Persister do
  let(:persister) { Sleipnir::Persistence::Memory::Adapter.new.persister }
  it_behaves_like "a Sleipnir::Persister"
end
