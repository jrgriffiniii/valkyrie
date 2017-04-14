# frozen_string_literal: true
module Valkyrie::Persistence::Fedora
  class DynamicKlass
    def self.new(orm_object)
      orm_object.internal_model.first.constantize.new(orm_object.attributes.merge("member_ids" => orm_object.ordered_member_ids.map { |x| Valkyrie::ID.new(x) }))
    end
  end
end
