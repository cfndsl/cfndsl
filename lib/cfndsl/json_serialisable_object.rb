module CfnDsl
  # JSONSerialisableObject
  module JSONSerialisableObject
    def as_json(_options = {})
      @value
    end

    def to_json(*a)
      as_json.to_json(*a)
    end
  end
end
