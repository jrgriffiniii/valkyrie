# frozen_string_literal: true
require 'rails_helper'
require 'sleipnir/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::ActiveFedora::Persister do
  let(:persister) { described_class }
  it_behaves_like "a Sleipnir::Persister", :no_deep_nesting, :no_mixed_nesting
end
