module HexGraph
  class BoardState

    def black_wins?
      @black_wins ||= (black_wins_naive? or black_wins_groups?)
    end
    
    def white_wins?
      @white_wins ||= (white_wins_naive? or white_wins_groups?)
    end

    def black_wins_naive?
      # black runs north-south, start at north edge
      # see if it gets to any cells in south edge
      north_set = [[1, 0]] #0 row is dummy row of black stones
      north_connected = connected_stones(north_set)
      north_connected.include?([1,@n+1])
    end
   
    def black_wins_groups?
      a_north_stone = [1,0]
      a_south_stone = [1,@n+1]

      north_connected_by_template, north_template_required = template_connected("north") 
      connected_to_north, @black_required = connected_groups([a_north_stone] + north_connected_by_template, north_template_required)#TODO: add template_required to connected_groups method
      return true if connected_to_north.include?(a_south_stone)
      south_connected_by_template, south_template_required = template_connected("south") 
      if (connected_to_north & south_connected_by_template).empty?
        false
      else
        @black_required += south_template_required
        true
      end
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
      connected_to_west, @white_required = connected_groups([a_west_stone])
      an_east_stone = [@n+1,1]
      connected_to_west.include?(an_east_stone) 
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
        return false if new_board.white_wins_recursive?
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
        return false if new_board.black_wins_recursive?
      end
      true
    end
  end
end
