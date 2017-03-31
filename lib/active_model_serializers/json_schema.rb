require "active_model_serializers/json_schema/version"
require "pathname"

module ActiveModelSerializers
  module JsonSchema
    def self.included(other_module)
      other_module.extend(ClassMethods)
    end

    module ClassMethods
      def json_schema(file:)
        file_path = Pathname.new(file)
        json = JSON.parse(file_path.read)
        type = json.fetch("type")

        if type == "object"
          attributes_from_schema = json.fetch("properties", {}).keys

          self.attributes(attributes_from_schema)
        end
      end
    end
  end
end
