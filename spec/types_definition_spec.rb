require 'spec_helper'

RSpec.describe 'Type Definitions' do
  aws_yaml = YAML.load_file File.expand_path('../../lib/cfndsl/aws/types.yaml', __FILE__)
  os_yaml = YAML.load_file File.expand_path('../../lib/cfndsl/os/types.yaml', __FILE__)
  new_yaml = YAML.load_file File.expand_path('../../new_types.yaml', __FILE__)

  { 'AWS' => aws_yaml, 'OS' => os_yaml, 'New' => new_yaml }.each_pair do |cloud, yaml|
    context cloud do
      resources = yaml['Resources']
      types = yaml['Types']

      context 'Resources' do
        resources.each do |name, info|
          it "#{name} has all property types defined" do
            properties = info['Properties']
            properties.each do |name, type|
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
              type.values.flatten.each{ |t| expect(types).to have_key(t) }
            else
              fail "A defined type should only be of the form String, Array or Hash, got #{type.class}"
            end
          end
        end
      end
    end
  end
end
