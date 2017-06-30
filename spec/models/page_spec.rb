# frozen_string_literal: true
require 'rails_helper'
require 'sleipnir/specs/shared_specs'

RSpec.describe Page do
  subject(:book) { described_class.new }
  let(:model_klass) { described_class }
  it_behaves_like "a Sleipnir::Model"
end
