require 'spec_helper'

# This is a somewhat temporary test class to compare functionality
# between the AWS, OS and new ways of defining types
RSpec.describe 'Type Definitions' do
  aws_spec = YAML.load_file File.expand_path('../lib/cfndsl/aws/types.yaml', __dir__)
  os_spec = YAML.load_file File.expand_path('../lib/cfndsl/os/types.yaml', __dir__)
  new_spec = CfnDsl::Specification.extract_from_resource_spec!

  { 'AWS' => aws_spec, 'OS' => os_spec, 'New' => new_spec }.each_pair do |cloud, specdef|
    context cloud do
      resources = specdef['Resources']
      types = specdef['Types']

      context 'Resources' do
        resources.each do |name, info|
          it "#{name} has all property types defined" do
            properties = info['Properties']
            properties.each_value do |type|
              type = type.first if type.is_a?(Array)
              expect(types).to have_key(type)
            end
          end
        end
      end

      context 'Types' do
        types.each do |name, type|
          it "#{name} has all property types defined" do
            type = type.first if type.is_a?(Array)
            if type.is_a?(String)
              expect(types).to have_key(type)
            elsif type.is_a?(Hash)
              type.values.flatten.each { |t| expect(types).to have_key(t) }
            else
              raise "A defined type should only be of the form String, Array or Hash, got #{type.class}"
            end
          end
        end
      end
    end
  end
end
