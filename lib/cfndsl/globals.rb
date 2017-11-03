# Global variables to adjust CfnDsl behavior
module CfnDsl
  module_function

  def disable_binding
    @disable_binding = true
  end

  def disable_binding?
    @disable_binding
  end

  def disable_deep_merge
    @disable_deep_merge = true
  end

  def disable_deep_merge?
    @disable_deep_merge
  end

  def specification_file(file = nil)
    @specification_file = file if file
    @specification_file ||= File.join(ENV['HOME'], '.cfndsl/resource_specification.json')
    @specification_file
  end

  def reserved_items
    %w[Resource Parameter Output].freeze
  end
end
