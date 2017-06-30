# frozen_string_literal: true
class FileSet < Sleipnir::Model
  include Sleipnir::Model::AccessControls
  attribute :id, Sleipnir::Types::ID.optional
  attribute :title, Sleipnir::Types::Set
  attribute :file_identifiers, Sleipnir::Types::Set
  attribute :member_ids, Sleipnir::Types::Array
end
