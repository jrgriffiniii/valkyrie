# frozen_string_literal: true
module Sleipnir::Persistence::Postgres
  class DynamicKlass
    def self.new(attributes)
      attributes[:internal_model].constantize.new(attributes)
    end
  end
end
