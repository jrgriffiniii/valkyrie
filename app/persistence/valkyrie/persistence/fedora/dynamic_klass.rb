# frozen_string_literal: true
module Valkyrie::Persistence::Fedora
  class DynamicKlass
    def self.new(orm_object)
      orm_object.internal_model.first.constantize.new(cast_attributes(orm_object).merge("member_ids" => orm_object.ordered_member_ids.map { |x| Valkyrie::ID.new(x) }))
    end

    def self.cast_attributes(orm_object)
      Hash[
        orm_object.attributes.map do |k, v|
          if v.is_a?(::ActiveTriples::Relation)
            v.rel_args = { cast: false }
            v = v.to_a
          end
          [k, v]
        end
      ]
    end
  end
end
