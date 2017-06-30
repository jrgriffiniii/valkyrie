# frozen_string_literal: true
class FileNode < Sleipnir::Model
  include Sleipnir::Model::AccessControls
  attribute :id, Sleipnir::Types::ID.optional
  attribute :label, Sleipnir::Types::Set
  attribute :mime_type, Sleipnir::Types::Set
  attribute :original_filename, Sleipnir::Types::Set
  attribute :file_identifiers, Sleipnir::Types::Set
  attribute :use, Sleipnir::Types::Set

  def title
    label
  end

  def download_id
    id
  end
end
