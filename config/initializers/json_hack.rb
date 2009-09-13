module ActiveRecord
  module Serialization
    class JsonSerializer < ActiveRecord::Serialization::Serializer #:nodoc:
      def serialize
        extra_values = options[:merge] || {}
        serializable_record.merge(extra_values).to_json
      end
    end
  end
end
