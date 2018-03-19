module CfnDsl
  # JSONSerialisableObject
  module JSONSerialisableObject
    def as_json(_options = {})
      @value
    end

    def to_json(*args)
      as_json.to_json(*args)
    end
  end
end
