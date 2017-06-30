# frozen_string_literal: true
require 'spec_helper'
require 'sleipnir/specs/shared_specs'

RSpec.describe Sleipnir::Persistence::Solr::QueryService do
  let(:adapter) { Sleipnir::Persistence::Solr::Adapter.new(connection: client) }
  let(:client) { RSolr.connect(url: SOLR_TEST_URL) }
  it_behaves_like "a Sleipnir query provider"
end
