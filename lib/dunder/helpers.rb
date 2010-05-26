# coding: utf-8

####
# helpers.rb
# http://github.com/bjorngylling/TDP019
# Part of the Dunder language project by Björn Gylling and Linus Karlsson
# This file contains helper-methods for the nodes

module Dunder
  module Helpers

    def look_up(name, scope)
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

    def assign(scope, name, value)
      scope[name] = value unless scope_assignement(scope, name, value)
    end
    
    def scope_assignement(scope, name, value)
      if scope.has_key? name
        scope[name] = value
        return true
      elsif scope.has_key? "PARENTSCOPE"
        # Check the variable exists in parent-scope, if it does we update it
        return scope_assignement(scope["PARENTSCOPE"], name, value)
      else
        return false
      end
    end
    
    def build_frame(parameters, arguments)
      Hash[*parameters.zip(arguments).flatten]
    end

  end
end

