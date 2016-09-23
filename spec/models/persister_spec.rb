require 'rails_helper'

RSpec.describe Persister do
  describe ".save" do
    it "saves a book and returns it with a UUID" do
      book = Book.new(title: "Test")

      output = Persister.save(book)

      expect(output.id).not_to be_blank
    end

    it "doesn't override a book that already has an ID" do
      book = Book.new(title: "Test", id: "5")
      
      output = Persister.save(book)

      expect(output.id).to eq "5"
    end

    it "can be found after being persisted" do
      book = Book.new(title: "Test")

      output = Persister.save(book)

      expect(find_book(book.id)).to eq output
    end
  end

  def find_book(id)
    FindByIdQuery.new(Book, id).run
  end
end
