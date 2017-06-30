# frozen_string_literal: true
require "spec_helper"

describe Sleipnir do
  it "has a version number" do
    expect(Sleipnir::VERSION).not_to be nil
  end
  it "can set a logger" do
    logger = described_class.logger
    fake_logger = instance_double(Logger)

    described_class.logger = fake_logger
    expect(described_class.logger).to eq fake_logger
    described_class.logger = logger
  end
  it "has a configuration loaded from Sleipnir's root" do
    expect { described_class.config }.not_to raise_error
  end
  it "can have a configured adapter, which it looks up" do
    memory_adapter = Sleipnir::Persistence::Memory::Adapter.new
    Sleipnir::Adapter.register(memory_adapter, :test)

    expect(described_class.config.adapter).to eq memory_adapter

    Sleipnir::Adapter.adapters = {}
  end

  it "can have a configured storage adapter, which it looks up" do
    storage_adapter = Sleipnir::FileRepository::Memory.new
    Sleipnir::FileRepository.register(storage_adapter, :test)

    expect(described_class.config.storage_adapter).to eq storage_adapter

    Sleipnir::FileRepository.repositories = {}
  end
  context "when Rails is defined and configured" do
    it "uses that path" do
      allow(Rails).to receive(:root).and_return(ROOT_PATH)

      described_class.config

      expect(Rails).to have_received(:root).exactly(2).times
    end
  end
end
