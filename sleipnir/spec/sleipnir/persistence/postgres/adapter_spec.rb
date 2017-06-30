# frozen_string_literal: true
require 'spec_helper'
require 'sleipnir/specs/shared_specs'

RSpec.describe Sleipnir::Persistence::Postgres::Adapter do
  let(:adapter) { described_class }
  it_behaves_like "a Sleipnir::Adapter"
end
