module HexGraph
  WHITE=1
  BLACK=-1
  EMPTY=0

  class BoardState
    N = 4 #memoized solver is hardcoded for a board size
    @@black_wins = Hash.new do |h,k|
      bs = BoardState.new(N)
      bs.from_i(k)
      if bs.black_wins?
        h[k] = true
      else
        h[k] = bs.black_wins_recursive?
      end
    end
      
    @@white_wins = Hash.new do |h,k|
      bs = BoardState.new(N)
      bs.from_i(k)
      if bs.white_wins?
        h[k] = true
      else
        h[k] = bs.white_wins_recursive?
      end
    end
    
    def initialize(board_size)
      @n = board_size
      @grid=Hash.new(EMPTY)
      set_edges
    end

    def black_wins?
      @black_wins ||= (black_wins_naive? or black_wins_groups?)
    end
    
    def white_wins?
      @white_wins ||= (white_wins_naive? or white_wins_groups?)
    end
   
    def reset
      @black_wins = nil
      @white_wins = nil
      @black_required = nil
      @white_required = nil
    end
   
    def black_required
      if @black_required
        @black_required
      else
        # gets set as a side-effect
        black_wins_groups?
        @black_required
      end
    end
    
    def white_required
      if @white_required
        @white_required
      else
        # gets set as a side-effect
        white_wins_groups?
        @white_required
      end
    end
    
    def set_edges
      (1..@n).each do |z|
        set_cell([0,z], WHITE)
        set_cell([@n+1, z], WHITE)
        set_cell([z, 0], BLACK)
        set_cell([z, @n+1], BLACK)
      end
    end

    def grid=(other)
      @grid=other
    end

    def clone
      new_bs = BoardState.new(@n)
      new_bs.grid=@grid.clone
      new_bs
    end

    def corners
      [[0,0],[0,@n+1],[@n+1,0],[@n+1,@n+1]]
    end

    def stones_of_color(color)
      stones = []
      (0..@n+1).each do |y|
        (0..@n+1).each do |x|
          stones << [x,y] if get_cell([x,y]) == color
        end
      end
      stones - corners
    end

    def populate_string(state)
      reset
      # B for Black, W for white, O for open.  One row at a time.
      state = state.gsub(" ", "")
      raise "#{state} Wrong length state string for board size #{@n}" unless state.size == @n*@n
      @grid = Hash.new(EMPTY)
      set_edges
      i=0
      state.each_char do |ch|
        x = (i % @n) + 1
        y = (i / @n) + 1
        set_cell([x,y], WHITE) if ch=='W'  
        set_cell([x,y], BLACK) if ch=='B' 
        i+=1 
      end
    end

    def to_base_4
      str = ""
      (1..@n).each do |y|
        (1..@n).each do |x|
          str << (get_cell([x,y]) % 4).to_s
        end
      end
      str
    end

    def from_base_4(str)
      reset
      # 3 for Black, 1 for white, 0 for open.  One row at a time.
      raise "#{str} Wrong length state string for board size #{@n}" unless str.size == @n*@n
      @grid = Hash.new(EMPTY)
      set_edges
      i=0
      str.each_char do |ch|
        x = (i % @n) + 1
        y = (i / @n) + 1
        set_cell([x,y], WHITE) if ch=='1'  
        set_cell([x,y], BLACK) if ch=='3' 
        i+=1 
      end
    end
       
    def to_i
      to_base_4.to_i(4)
    end
    def from_i(i)
      from_base_4(i.to_s(4).rjust(@n*@n,"0"))
    end  

    def get_cell(coord)
      @grid[coord]
    end

    def set_cell(coord, value)
      reset
      validate_coords(coord)
      @grid[coord]=value
    end

    def print_board
      (0..@n+1).each do |y|
        y.times{print " "}
        (0..@n+1).each do |x|
          print "W" if get_cell([x,y])==WHITE
          print "B" if get_cell([x,y])==BLACK
          print "_" if get_cell([x,y])==EMPTY
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

    # coord is a list: [x,y]
    def adjacent_to(coord)
      validate_coords(coord)
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
        adj += adjacent_to(cell)
      end
      adj.uniq.select{|cell| get_cell(cell)==EMPTY}
    end

    # assumes white to move
    def black_wins_recursive?
      # Check if White has any obviously winning move
      (stones_of_color(EMPTY)).shuffle.each do |move|
        new_board = clone
        new_board.set_cell(move, WHITE)
        return false if new_board.white_wins?
      end

      # Apply the recursive check
      must_play(BLACK).shuffle.each do |move|
        new_board = clone
        new_board.set_cell(move, WHITE)
        return false if @@white_wins[new_board.to_i]
      end
      true
    end

    def white_wins_recursive?
      (stones_of_color(EMPTY)).shuffle.each do |move|
        new_board = clone
        new_board.set_cell(move, BLACK)
        return false if new_board.black_wins?
      end
      must_play(WHITE).shuffle.each do |move|
        new_board = clone
        new_board.set_cell(move, BLACK)
        return false if @@black_wins[new_board.to_i]
      end
      true
    end

    # color is the color of the player who's stones must
    # be intruded upon
    def must_play(color)
      needed_cells = []
      stones_of_color(EMPTY).each do |move|
        new_board = clone
        new_board.set_cell(move, color)
        if color == WHITE and new_board.white_wins?
          needed_cells << new_board.white_required + [move]
        elsif color == BLACK and new_board.black_wins?
          needed_cells << new_board.black_required + [move]
        end
      end
      must_play_cells = stones_of_color(EMPTY)
      needed_cells.each do |set_of_cells|
        must_play_cells &= set_of_cells
      end
      must_play_cells
    end

    def black_wins_naive?
      # black runs north-south, start at north edge
      # see if it gets to any cells in south edge
      north_set = [[1, 0]] #0 row is dummy row of black stones
      north_connected = connected_stones(north_set)
      north_connected.include?([1,@n+1])
    end
   
    def black_wins_groups?
      # get group connected to north
      a_north_stone = [1,0]
      connected_to_north, @black_required = connected_groups(a_north_stone)
      a_south_stone = [1,@n+1]
      connected_to_north.include?(a_south_stone) 
    end
    
    def white_wins_naive?
      # white runs east-west, start at west edge
      # see if it gets to any cells in east edge
      west_set = [[0, 1]] #0 column is dummy column of white stones
      west_connected = connected_stones(west_set)
      west_connected.include?([@n+1,1])
    end
   
    def white_wins_groups?
      # get group connected to north
      a_west_stone = [0,1]
      connected_to_west, @white_required = connected_groups(a_west_stone)
      an_east_stone = [@n+1,1]
      connected_to_west.include?(an_east_stone) 
    end

    # Returns a list of stones connected to the stone at the
    # specified cell.  This connection assumes that two empty
    # cells between two stones allows a connection to be formed
    def connected_groups(starting_stone)
      groups = [connected_stones([starting_stone])]
      color = get_cell(starting_stone)
      stones_of_color(color).each do |cell|
        next if groups.flatten(1).include?(cell)
        groups << connected_stones([cell])
      end
      base_group = groups[0]
      unmatched = groups[1..groups.size]
      required_open_groups = []
      new_unmatched = []
      loop do
        unmatched.each do |g|
          base_adj = open_adjacent_to_group(base_group)
          g_adj = open_adjacent_to_group(g)
          intersection_of_adjacent = base_adj & g_adj
          if (intersection_of_adjacent).size > 1  #if two ways to connect
            overlap_fail = false
            required_open_groups.each_with_index do |open_group, ind|
              overlap = open_group & intersection_of_adjacent
              next if overlap.empty?
              if open_group.size == 2 and intersection_of_adjacent.size == 2
                overlap_fail = true # both are min size, and overlap not empty
                break
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
              base_group += g
              required_open_groups << intersection_of_adjacent
            else
              new_unmatched << g
            end
          else
            new_unmatched << g
          end
        end
        break if unmatched == new_unmatched
        unmatched = new_unmatched
        new_unmatched = []
      end
      return base_group, required_open_groups.flatten(1)
      
    end
    
    def connected_stones(list_of_cells)
      return [] if list_of_cells.empty?
      color = get_cell(list_of_cells.first)
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
          adjacent_to(coord).each do |adj_coord|
            if get_cell(adj_coord) == color
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
