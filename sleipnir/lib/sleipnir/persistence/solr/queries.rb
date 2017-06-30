# frozen_string_literal: true
module Sleipnir::Persistence::Solr
  module Queries
    require 'sleipnir/persistence/solr/queries/default_paginator'
    require 'sleipnir/persistence/solr/queries/find_all_query'
    require 'sleipnir/persistence/solr/queries/find_by_id_query'
    require 'sleipnir/persistence/solr/queries/find_inverse_references_query'
    require 'sleipnir/persistence/solr/queries/find_members_query'
    require 'sleipnir/persistence/solr/queries/find_references_query'
  end
end
