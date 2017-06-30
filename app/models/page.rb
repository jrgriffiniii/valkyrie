# frozen_string_literal: true
class Page < Sleipnir::Model
  include Sleipnir::Model::AccessControls
  attribute :id, Sleipnir::Types::ID.optional
  attribute :title, Sleipnir::Types::Set
  attribute :viewing_hint, Sleipnir::Types::Set
end
