module HexGraph
  WHITE=1
  BLACK=-1
  EMPTY=0

  class BoardState
    def initialize(board_size)
      @n = board_size
      @grid=Hash.new(EMPTY)
      self.set_edges
    end

    def set_edges
      (1..@n).each do |z|
        self.set_cell([0,z], WHITE)
        self.set_cell([@n+1, z], WHITE)
        self.set_cell([z, 0], BLACK)
        self.set_cell([z, @n+1], BLACK)
      end
    end

    def set_cell(coord, value)
      self.validate_coords(coord)
      @grid[coord]=value
    end

    def stones_of_color(color)
      stones = []
      (1..@n).each do |y|
        (1..@n).each do |x|
          stones << [x,y] if self.get_cell([x,y]) == color
        end
      end
      stones
    end

    def populate_string(state)
      # B for Black, W for white, O for open.  One row at a time.
      state = state.gsub(" ", "")
      raise "#{state} Wrong length state string for board size #{@n}" unless state.size == @n*@n
      @grid = Hash.new(EMPTY)
      self.set_edges
      i=0
      state.each_char do |ch|
        x = (i % @n) + 1
        y = (i / @n) + 1
        self.set_cell([x,y], WHITE) if ch=='W'  
        self.set_cell([x,y], BLACK) if ch=='B' 
        i+=1 
      end
    end

    def get_cell(coord)
      @grid[coord]
    end

    def print_board
      (1..@n).each do |y|
        y.times{print " "}
        (1..@n).each do |x|
          print "W" if self.get_cell([x,y])==WHITE
          print "B" if self.get_cell([x,y])==BLACK
          print "_" if self.get_cell([x,y])==EMPTY
          print " "
        end
        puts " "
      end
    end

    def validate_coords(coord)
      raise "Coordinates must be passed as an array" unless coord.is_a?(Array)
      raise "Coordinates must have two values" unless coord.size == 2
      coord.each do |co|
        raise "Coordinates must not be negative" if co < 0
        raise "Coordinates must be no greater than #{@n+1} on a #{@n}x#{@n} board" if co > @n+1
      end
    end

    def adjacent_to(coord)
      self.validate_coords(coord)
      x, y = coord
      results = []
      results << [x-1, y] if x > 0
      results << [x+1, y] if x < @n+1
      results << [x, y-1] if y > 0
      results << [x, y+1] if y < @n+1
      results << [x-1, y+1] if x > 0 and y < @n+1
      results << [x+1, y-1] if x < @n+1 and y > 0
      results
    end

    def open_adjacent_to_group(group)
      adj = []
      group.each do |cell|
        adj += self.adjacent_to(cell)
      end
      adj.uniq.select{|cell| self.get_cell(cell)==EMPTY}
    end

    def black_wins_naive?
      # black runs north-south, start at north edge
      # breadth first graph expansion
      # see if it gets to any cells in south edge
      north_set = [[1, 0]] #0 row is dummy row of black stones
      north_connected = connected_stones(north_set)
      return true if north_connected.include?([1,@n+1])
      false
    end
   
    def black_wins?
      self.black_wins_groups?
    end
    
    def black_wins_groups?
      return true if black_wins_naive?
      groups = []
      
      # get group connected to north
      north_set = [[1,0]]
      north_connected = connected_stones(north_set)
      groups << north_connected

      # get group connected to south
      south_set = [[1,@n+1]]
      south_connected = connected_stones(south_set)
      groups << south_connected

      # get remaining groups
      # We can assume groups[0] is north and groups[1] is south
      self.stones_of_color(BLACK).each do |cell|
        next if groups.flatten(1).include?(cell)
        groups << self.connected_stones([cell])
      end

      north = groups[0]
      south = groups[1]
      unmatched = groups[1..groups.size]
      required_open_groups = []
      new_unmatched = []
      loop do
        unmatched.each do |g|
          north_adj = self.open_adjacent_to_group(north)
          g_adj = self.open_adjacent_to_group(g)
          intersection_of_adjacent = north_adj & g_adj
          if (intersection_of_adjacent).size > 1
            overlap_fail = false
            required_open_groups.each_with_index do |open_group, ind|
              overlap = open_group & intersection_of_adjacent
              break if overlap.empty?
              if open_group.size == 2 and intersection_of_adjacent.size == 2
                overlap_fail = true
                break
              ## This logic needs to be broader, how to handle
              # case where open group is 3 and i_o_a is 3 but they have
              # an overlap of 2, for example
              elsif intersection_of_adjacent == 2
                o_minus_i = open_group - intersection_of_adjacent
                if o_minus_i.size > 1
                  required_open_groups[ind] = o_minus_i
                else
                  overlap_fail = true
                  break
                end
              elsif open_group.size == 2
                i_minus_o = intersection_of_adjacent - open_group
                if i_minus_o.size > 1
                  intersection_of_adjacent = i_minus_o
                else
                  overlap_fail = true
                  break
                end
              #elsif both groups are bigger than 2, turn them into
              #disjoint subsets
              end

            end
            unless overlap_fail
              north += g
              required_open_groups += intersection_of_adjacent
            end
          else
            new_unmatched << g
          end
        end
        break if unmatched == new_unmatched
        unmatched = new_unmatched
      end
      return (north & south).size > 0
      
    end
    
    def connected_stones(list_of_cells)
      return [] if list_of_cells.empty?
      color = self.get_cell(list_of_cells.first)
      raise "list_of_cells not black or white" if color == EMPTY
      list_of_cells.each do |cell|
        raise "list_of_cells contain different colored stones" unless get_cell(cell) == color
      end
      one_set = []
      working_set = list_of_cells
      new_set = []
      loop do
        one_set += working_set
        working_set.each do |coord|
          self.adjacent_to(coord).each do |adj_coord|
            if self.get_cell(adj_coord) == color
              unless one_set.include?(adj_coord)
                new_set << adj_coord
              end
            end
          end
        end
        break if new_set.size == 0
        one_set += working_set
        working_set = new_set
        new_set = []
      end
      one_set.uniq
    end
  end

end
