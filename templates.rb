module HexGraph


# Each template is a set of coordinates
# relative to the stone and the edge
# assuming an attempted connection to
# the bottom 
  class Template
    # open - set of open cells needed
    # taken - set of cells needed to already have a stone
    # asymmetric - the mirror of this template is a different template
    # level - which row away is the stone
    def initialize(level, asymmetric, open, taken=[])
      @level = level
      @asymmetric = asymmetric
      @open = open
      @taken = taken
    end
    def level
      @level
    end
    def asymmetric?
      @assumentric
    end
    def open
      @open
    end
    def taken
      @taken
    end
  end
end
TEMPLATES = [
  #2-3-4
  HexGraph::Template.new(3, true, [[1,0],[-1,1],[0,1],[1,1],[-2,2],[-1,2],[0,2],[1,2]])
  ]
