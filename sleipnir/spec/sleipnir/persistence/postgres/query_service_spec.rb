# frozen_string_literal: true
require 'spec_helper'
require 'sleipnir/specs/shared_specs'

RSpec.describe Sleipnir::Persistence::Postgres::QueryService do
  let(:adapter) { Sleipnir::Persistence::Postgres::Adapter }
  it_behaves_like "a Sleipnir query provider"
end
