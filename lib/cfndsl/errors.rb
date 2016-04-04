module CfnDsl
  # Keeps track of errors
  module Errors
    @errors = []

    def self.error(err, idx = nil)
      if idx.nil?
        @errors.push(err + "\n" + caller.join("\n") + "\n")
      else
        m = caller[idx].match(/^.*?:\d+:/)
        err_loc = m ? m[0] : caller[idx]

        @errors.push(err_loc + ' ' + err + "\n")
      end
    end

    def self.clear
      @errors = []
    end

    def self.errors
      @errors
    end

    def self.errors?
      !@errors.empty?
    end
  end
end
