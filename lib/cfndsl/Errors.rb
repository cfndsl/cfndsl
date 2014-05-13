module CfnDsl
  module Errors
    @@errors = []

    def self.error( err, idx=nil )
      if(idx.nil?) then
        @@errors.push ( err + "\n" + caller.join("\n") + "\n" )
      else
        if( m = caller[idx].match(/^.*?:\d+:/ ) ) then
          err_loc = m[0];
        else
          err_loc = caller[idx]
        end

        @@errors.push ( err_loc + " " + err + "\n" )
      end
    end

    def self.clear()
      @@errors = []
    end

    def self.errors()
      @@errors
    end

    def self.errors?()
      return @@errors.length > 0
    end
  end
end
