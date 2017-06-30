# frozen_string_literal: true
require 'rails_helper'
require 'sleipnir/specs/shared_specs'

RSpec.describe Collection do
  let(:model_klass) { described_class }
  it_behaves_like "a Sleipnir::Model"
end
