module HexGraph
  class BoardState

    def template_connected(direction)
      raise "template_connected only valid for directions north, south, east, or west" unless %w{north south east west}.include?(direction)
      connected_stones = []
      required_empty = []
      color = case direction
        when "north", "south"
          BLACK
        when "east", "west"
          WHITE
      end
      TEMPLATES.each do |base_template|
        template = case direction
          when "north"
            base_template.north
          when "south"
            base_template.south
          when "east"
            base_template.east
          when "west"
            base_template.west
        end
        level_stones = stones_of_color(color).select do |x,y| 
          case direction
            when "south"
              y==@n+1-template.level 
            when "north"
              y==template.level
            when "west"
              x==template.level
            when "east"
              x==@n+1-template.level
          end
        end
        level_stones.each do |stone|
          x, y = stone
          if template.open.all?{|i,j| [color, EMPTY].include?(get_cell([x+i,y+j]))}
            if template.taken.all?{|i,j| get_cell([x+i,y+j]) == color}
              connected_stones << stone
              required_empty << template.open.map{|i,j| [x+i,y+j]}
            end
          end
        end
      end
      return connected_stones, required_empty.flatten(1)
    end


  end
end
