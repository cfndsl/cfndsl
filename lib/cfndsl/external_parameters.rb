module CfnDsl
  # Handles all external parameters
  class ExternalParameters
    extend Forwardable

    def_delegators :parameters, :fetch, :keys, :values, :each_pair

    attr_reader :parameters

    class << self
      def defaults(params = {})
        @defaults ||= {}
        @defaults.merge! params
        @defaults
      end

      def current
        @current || refresh!
      end

      def refresh!
        @current = new
      end
    end

    def initialize
      @parameters = self.class.defaults.clone
    end

    def set_param(key, val)
      parameters[key.to_sym] = val
    end

    def merge_param(xray)
      parameters.deep_merge!(xray)
    end

    def get_param(key)
      parameters[key.to_sym]
    end
    alias [] get_param

    def to_h
      parameters
    end

    def add_to_binding(bind, logstream)
      parameters.each_pair do |key, val|
        logstream.puts("Setting local variable #{key} to #{val}") if logstream
        bind.eval "#{key} = #{val.inspect}"
      end
    end

    def load_file(fname)
      format = File.extname fname
      case format
      when /ya?ml/
        params = YAML.load_file fname
      when /json/
        params = JSON.parse File.read(fname)
      else
        raise "Unrecognized extension #{format}"
      end
      if CfnDsl.disable_deep_merge?
        params.each { |key, val| set_param(key, val) }
      else
        x = {}
        params.map { |k, v| x[k.to_sym] = v }
        merge_param(x)
      end
    end
  end
end
