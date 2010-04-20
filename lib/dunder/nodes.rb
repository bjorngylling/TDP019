module Dunder
  module Nodes
    
    class Node
      
      def self.sub_classes
        sub_classes = ObjectSpace.enum_for(:each_object, class << self; self; end).to_a
        sub_classes.delete(self)
        
        sub_classes
      end
      
      def is_node?
        true
      end
      
    end
    
    class Addition < Node
      attr_accessor :lh, :rh
      
      def eval()
        (@lh.is_node? ? @lh.eval : @lh) + (@rh.is_node? ? @rh.eval : @rh)
      end
    end
    
    class Subtraction < Node
      attr_accessor :lh, :rh
      
      def eval()
        @lh - @rh
      end
    end
    
    class Multiplication < Node
      attr_accessor :lh, :rh
      
      def eval()
        @lh * @rh
      end
    end
    
    class Division < Node
      attr_accessor :lh, :rh
      
      def eval()
        @lh / @rh
      end
    end
    
    class IfStatement < Node
      attr_accessor :condition, :code_block
      
      def eval()
        if @condition.eval()
          return @code_block.eval()
        end
      end
    end
    
  end
end