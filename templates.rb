module HexGraph


# Each template is a set of coordinates
# relative to the stone and the edge
# assuming an attempted connection to
# the bottom 
  class Template
    # open - set of open cells needed (wrt stone at [0,0])
    # taken - set of cells needed to already have a stone
    # asymmetric - the mirror of this template is a different template
    # level - which row away is the stone
    def initialize(level, asymmetric, open, taken=[], orientation="south")
      @level = level
      @asymmetric = asymmetric
      @open = open
      @taken = taken
      @orientation = orientation
      (@open+@taken).each {|pair| raise "Template must be sets of coordinate pairs" unless pair.size == 2}
      raise "Template open and taken sets must not overlap" unless (@open & @taken).empty?
    end
    def level
      @level
    end
    def asymmetric?
      @asymmetric
    end
    def open
      @open
    end
    def taken
      @taken
    end

    def reflection
      raise "Only reflect a South template" unless @orientation == "south"
      new_open = @open.map{|x,y| [-x-y,y]}
      new_taken = @taken.map{|x,y| [-x-y,y]}
      Template.new(@level, @asymmetric, new_open, new_taken)
    end
    
    def south
      raise "Only change the orientation of a South template" unless @orientation == "south"
      self
    end
    def north
      raise "Only change the orientation of a South template" unless @orientation == "south"
      new_open = @open.map{|x,y| [-x,-y]}
      new_taken = @taken.map{|x,y| [-x,-y]}
      Template.new(@level, @asymmetric, new_open, new_taken, "north")
    end 
    def west
      raise "Only change the orientation of a South template" unless @orientation == "south"
      new_open = @open.map{|x,y| [-y,-x]}
      new_taken = @taken.map{|x,y| [-y,-x]}
      Template.new(@level, @asymmetric, new_open, new_taken, "west")
    end 
    def east
      raise "Only change the orientation of a South template" unless @orientation == "south"
      new_open = @open.map{|x,y| [y,x]}
      new_taken = @taken.map{|x,y| [y,x]}
      Template.new(@level, @asymmetric, new_open, new_taken, "east")
    end 
  end
end
TEMPLATES = [
  #2-3-4
  HexGraph::Template.new(3, true, [[1,0],[-1,1],[0,1],[1,1],[-2,2],[-1,2],[0,2],[1,2]])
  ].map{|t| t.asymmetric? ? [t, t.reflection] : [t]}.flatten(1) 
