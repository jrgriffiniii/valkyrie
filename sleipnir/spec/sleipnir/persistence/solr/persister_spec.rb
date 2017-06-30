# frozen_string_literal: true
require 'spec_helper'
require 'sleipnir/specs/shared_specs'

RSpec.describe Sleipnir::Persistence::Solr::Persister do
  let(:persister) { adapter.persister }
  let(:adapter) { Sleipnir::Persistence::Solr::Adapter.new(connection: client) }
  let(:client) { RSolr.connect(url: SOLR_TEST_URL) }
  it_behaves_like "a Sleipnir::Persister"

  context "when given additional persisters" do
    let(:adapter) { Sleipnir::Persistence::Solr::Adapter.new(connection: client, resource_indexer: indexer) }
    let(:indexer) { ResourceIndexer }
    before do
      class ResourceIndexer
        attr_reader :resource
        def initialize(resource:)
          @resource = resource
        end

        def to_solr
          {
            "combined_title_ssim" => resource.title + resource.other_title
          }
        end
      end
      class Resource < Sleipnir::Model
        attribute :id, Sleipnir::Types::ID.optional
        attribute :title, Sleipnir::Types::Set
        attribute :other_title, Sleipnir::Types::Set
      end
    end
    after do
      Object.send(:remove_const, :ResourceIndexer)
      Object.send(:remove_const, :Resource)
    end
    it "can add custom indexing" do
      b = Resource.new(title: ["Test"], other_title: ["Author"])
      expect(adapter.resource_factory.from_model(b)["combined_title_ssim"]).to eq ["Test", "Author"]
    end
    context "when told to index a really long string" do
      let(:adapter) { Sleipnir::Persistence::Solr::Adapter.new(connection: client) }
      it "works" do
        b = Resource.new(title: "a" * 100_000)
        expect { adapter.persister.save(model: b) }.not_to raise_error
      end
    end
  end
end
