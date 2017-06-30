# frozen_string_literal: true
class FileSetForm < Sleipnir::Form
  self.fields = FileSet.fields - [:id, :internal_model, :created_at, :updated_at]
end
