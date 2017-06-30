# frozen_string_literal: true
module Sleipnir
  module Types
    include Dry::Types.module
    ID = Dry::Types::Definition
         .new(Sleipnir::ID)
         .constructor do |input|
           Sleipnir::ID.new(input)
         end
    Anything = Sleipnir::Types::Any.constructor do |value|
      if value.respond_to?(:fetch) && value.fetch(:internal_model, nil)
        value.fetch(:internal_model).constantize.new(value)
      else
        value
      end
    end
    Set = Sleipnir::Types::Coercible::Array.constructor do |value|
      value.select(&:present?).uniq.map do |val|
        Anything[val]
      end
    end.default([])
    Array = Dry::Types['coercible.array'].default([])
    SingleValuedString = Sleipnir::Types::String.constructor do |value|
      ::Array.wrap(value).first.to_s
    end
  end
end
