# frozen_string_literal: true
class Book < Sleipnir::Model
  include Sleipnir::Model::AccessControls
  attribute :id, Sleipnir::Types::ID.optional
  attribute :title, Sleipnir::Types::Set
  attribute :author, Sleipnir::Types::Set
  attribute :testing, Sleipnir::Types::Set
  attribute :member_ids, Sleipnir::Types::Array
  attribute :a_member_of, Sleipnir::Types::Set
  attribute :viewing_hint, Sleipnir::Types::Set
  attribute :viewing_direction, Sleipnir::Types::Set
  attribute :thumbnail_id, Sleipnir::Types::Set
  attribute :representative_id, Sleipnir::Types::Set
  attribute :start_canvas, Sleipnir::Types::Set
end
