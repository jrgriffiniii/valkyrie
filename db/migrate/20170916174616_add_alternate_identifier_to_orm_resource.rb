class AddAlternateIdentifierToOrmResource < ActiveRecord::Migration[5.1]
  def change
    add_column :orm_resources, :alternate_identifier, :string

    add_index :orm_resources, :alternate_identifier, unique: true
  end
end
