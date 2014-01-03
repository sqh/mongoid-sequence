require "mongoid-sequence/version"
require "active_support/concern"

module Mongoid
  module Sequence
    extend ActiveSupport::Concern

    included do
      set_callback :validate, :before, :set_sequence, :unless => :persisted?
    end

    module ClassMethods
      attr_accessor :sequence_fields

      def sequence(field)
        self.sequence_fields ||= []
        self.sequence_fields << field
      end
    end

    def set_sequence
      collection = self.mongo_session[:__sequences]
      criteria = Criteria.new
      criteria.find("#{self.class.name.underscore}_#{field}")
      self.class.sequence_fields.each do |field|
        next_sequence = FindAndModify.new(collection, criteria, {'$inc' => {seq: 1}}, new: true, upsert: true).result

        self[field] = next_sequence['seq']
      end if self.class.sequence_fields
    end
  end
end
