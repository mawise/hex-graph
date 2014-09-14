module HexGraph
  WHITE=1
  BLACK=-1
  EMPTY=0

  class BoardState

    def initialize(board_size)
      @n = board_size
      @grid=Hash.new(EMPTY)
      set_edges
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
        raise "Can't check black_required unless black_wins_groups" unless black_wins_groups?
        @black_required
      end
    end
    
    def white_required
      if @white_required
        @white_required
      else
        # gets set as a side-effect
        raise "Can't check white_required unless white_wins_groups" unless white_wins_groups?
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

  end

end
