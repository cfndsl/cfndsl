# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Type Definitions' do
  new_spec = CfnDsl::Types.extract_from_resource_spec(fail_patches: true)

  { 'New' => new_spec }.each_pair do |cloud, specdef|
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
            type = type['Properties'] if type.is_a?(Hash) && type.key?('Properties')
            type = type.first if type.is_a?(Array)
            case type
            when String
              expect(types).to have_key(type)
            when Hash
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
