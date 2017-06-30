# frozen_string_literal: true
require 'spec_helper'
require 'sleipnir/specs/shared_specs'

RSpec.describe Sleipnir::Persistence::Postgres::Persister do
  let(:persister) { described_class }
  it_behaves_like "a Sleipnir::Persister"
end
