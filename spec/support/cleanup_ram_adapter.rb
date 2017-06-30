# frozen_string_literal: true
RSpec.configure do |config|
  config.before(:each) do
    Sleipnir::Adapter.adapters.values.each do |adapter|
      next unless adapter.is_a?(Sleipnir::Persistence::Memory::Adapter)
      adapter.cache = {}
    end
  end
end
