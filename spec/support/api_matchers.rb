RSpec::Matchers.define :be_valid_json do
  match do |actual|
    expect(actual["Content-Type"]).to eq "application/json"
  end
end

RSpec::Matchers.define :be_json_ready do
  match do |actual|
    begin
      expect(JSON.parse(JSON.generate(actual))).to eq actual
    rescue JSON::GeneratorError
      raise "#{actual} is not JSON serializable!"
    end
  end
end

RSpec::Matchers.define :match_response_schema do |schema|
  match do |body|
    schema_directory = "#{Dir.pwd}/spec/support/api/schemas"
    schema_path = "#{schema_directory}/#{schema}.json"
    begin
      JSON::Validator.validate!(schema_path, body, strict: true)
    rescue Errno::ENOENT
      raise "Schema '#{schema}' doesn't exist! Create a schema file in 'spec/support/api/schemas/#{schema}.json'."
    rescue JSON::ParserError
      raise "Schema '#{schema}' is not valid! Please update it in 'spec/support/api/schemas/#{schema}.json'."
    end
  end
end
