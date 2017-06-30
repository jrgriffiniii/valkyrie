# frozen_string_literal: true
class Collection < Sleipnir::Model
  include Sleipnir::Model::AccessControls
  attribute :id, Sleipnir::Types::ID.optional
  attribute :title, Sleipnir::Types::Set
end
