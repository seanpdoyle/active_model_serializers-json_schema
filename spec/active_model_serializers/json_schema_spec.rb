require "spec_helper"
require "active_model_serializers"

RSpec.describe ActiveModelSerializers::JsonSchema do
  it "has a version number" do
    expect(ActiveModelSerializers::JsonSchema::VERSION).not_to be nil
  end

  context "when the path to the JSON Schema is configured" do
    it "declares attributes based on a JSON Schema" do
      schema_file = create_schema("article", <<-JS)
        {
          "type": "object",
          "properties": {
            "id": { "type": "integer" },
            "title": { "type": "string" },
            "body": { "type": "string" },
            "created_at": { "type": "date" }
          }
        }
      JS
      serializer_class = Class.new(ActiveModel::Serializer) do
        include ActiveModelSerializers::JsonSchema

        json_schema file: schema_file.path
      end
      article_class = Class.new do
        include ActiveModel::Model
        include ActiveModel::Serialization

        attr_accessor :body, :created_at, :id, :title
      end
      article = article_class.new(
        id: 1,
        title: "The Article",
        body: "The body of the article",
        created_at: DateTime.new(2017, 1, 1, 0, 0, 0),
      )
      serializer = serializer_class.new(article)

      payload = serializer.serializable_hash

      expect(payload).to eq(
        "id" => article.id,
        "title" => article.title,
        "body" => article.body,
        "created_at" => "2017-01-01",
      )
    end
  end

  def create_schema(name, json)
    tempfile = Tempfile.new(name)
    tempfile.write(json.to_s)
    tempfile.close
    tempfile
  end
end
