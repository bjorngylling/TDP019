module Dunder
  module Helpers

    def self.look_up(name, scope)
      if scope.include?(name)
          return scope[name]
        else
          if scope.has_key? "PARENTSCOPE"
            # Go up one scope and look for it there
            return look_up(name, scope["PARENTSCOPE"])
          elsif scope.has_key? "OUTSIDE_FUNCTION_DEF"
            # Go up one scope and look for it there
            return look_up(name, scope["OUTSIDE_FUNCTION_DEF"])
          else
            return false
          end
        end
    end

    def self.assign(scope, name, value)
      if scope.has_key? name
        scope[name] = value
        return true
      elsif scope.has_key? "PARENTSCOPE"
        # Check the variable exists in parent-scope, if it does we update it
        return assign(scope["PARENTSCOPE"], name, value)
      else
        return false
      end
    end

  end
end

