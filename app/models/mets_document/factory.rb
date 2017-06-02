# frozen_string_literal: true
class METSDocument
  class Factory
    attr_reader :mets
    def initialize(mets)
      @mets = METSDocument.new(mets)
    end

    def new
      mets
    end

    private

      def pudl3_mvw?
        mets.collection_slugs == "pudl0003" && mets.mets.xpath("/mets:mets/mets:structMap[@type='Physical']").empty?
      end
  end
end
