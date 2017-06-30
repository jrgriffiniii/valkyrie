# frozen_string_literal: true
require 'spec_helper'
require 'sleipnir/specs/shared_specs'

RSpec.describe Sleipnir::Persistence::Solr::Adapter do
  let(:adapter) { described_class.new(connection: client) }
  let(:client) { RSolr.connect(url: SOLR_TEST_URL) }
  it_behaves_like "a Sleipnir::Adapter"
end
