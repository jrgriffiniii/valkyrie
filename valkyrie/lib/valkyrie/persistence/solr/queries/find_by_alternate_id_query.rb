# frozen_string_literal: true
module Valkyrie::Persistence::Solr::Queries
  class FindByAlternateIdQuery < FindByIdQuery
    def resource
      connection.get("select", params: { q: "alternate_identifier_ssim:\"#{id}\"", fl: "*", rows: 1 })["response"]["docs"].first
    end
  end
end
