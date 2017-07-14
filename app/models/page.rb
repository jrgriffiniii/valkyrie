# frozen_string_literal: true
class Page < Valkyrie::Resource
  include Valkyrie::Resource::AccessControls
  attribute :id, Valkyrie::Types::ID.optional
  attribute :title, Valkyrie::Types::Set
  attribute :viewing_hint, Valkyrie::Types::Set
  attribute :member_ids, Valkyrie::Types::Array
end
