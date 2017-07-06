# frozen_string_literal: true
require 'rails_helper'

RSpec.describe IngestMETSJob, :admin_set do
  describe "integration test" do
    let(:user) { FactoryGirl.build(:admin) }
    let(:mets_file) { Rails.root.join("spec", "fixtures", "pudl0001-4612596.mets") }
    let(:tiff_file) { Rails.root.join("spec", "fixtures", "files", "color.tif") }
    let(:mime_type) { 'image/tiff' }
    let(:file) { IoDecorator.new(File.new(tiff_file), mime_type, File.basename(tiff_file)) }
    let(:order) do
      {
        nodes: [{
          label: 'leaf 1', nodes: [{
            label: 'leaf 1. recto', proxy: fileset2.id
          }]
        }]
      }
    end

    before do
      allow(File).to receive(:open).and_call_original
      allow(File).to receive(:open).with("/tmp/pudl0001/4612596/00000001.tif").and_return(File.open(tiff_file))
      allow(File).to receive(:open).with("/users/escowles/downloads/tmp/00000001.tif").and_return(File.open(tiff_file))
      allow(File).to receive(:open).with("/users/escowles/downloads/tmp/00000002.tif").and_return(File.open(tiff_file))
      allow(File).to receive(:open).with("/users/escowles/downloads/tmp/00000003.tif").and_return(File.open(tiff_file))
      allow(File).to receive(:open).with("/users/escowles/downloads/tmp/00000657.tif").and_return(File.open(tiff_file))
      allow(File).to receive(:open).with("/users/escowles/downloads/tmp/00000658.tif").and_return(File.open(tiff_file))
      allow(File).to receive(:open).with("/users/escowles/downloads/tmp/00000659.tif").and_return(File.open(tiff_file))
    end

    let(:adapter) { Valkyrie.config.adapter }
    it "ingests a METS file" do
      described_class.perform_now(mets_file, user)

      book = adapter.query_service.find_all.reverse.first
      expect(book).not_to be_nil
      expect(book.source_metadata_identifier).to eq ["4612596"]
      expect(book.structure[0].nodes.length).to eq 1
      expect(book.structure[0].nodes[0].label).to contain_exactly 'leaf 1'
      expect(book.structure[0].nodes[0].nodes[0].label).to contain_exactly 'leaf 1. recto'
      expect(book.member_ids).not_to be_blank
      file_sets = adapter.query_service.find_members(model: book)
      expect(book.structure[0].nodes[0].nodes[0].proxy).to eq file_sets.first.id
      expect(file_sets.first.title).to eq ["leaf 1. recto"]
    end

    context "when given a MVW" do
      let(:mets_file) { Rails.root.join("spec", "fixtures", "pudl0001-4609321-s42.mets") }
      it "ingests it" do
        described_class.perform_now(mets_file, user)

        books = adapter.query_service.find_all_of_model(model: Book)
        expect(books.length).to eq 3
        binding.pry
      end
    end
  end
end
