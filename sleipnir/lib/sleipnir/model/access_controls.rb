# frozen_string_literal: true
module Sleipnir
  class Model
    module AccessControls
      def self.included(klass)
        klass.attribute :read_groups, Sleipnir::Types::Set
        klass.attribute :read_users, Sleipnir::Types::Set
        klass.attribute :edit_users, Sleipnir::Types::Set
        klass.attribute :edit_groups, Sleipnir::Types::Set
      end
    end
  end
end
