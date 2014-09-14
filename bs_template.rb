module HexGraph
  class BoardState
    def template_connected_south
      connected_stones = []
      TEMPLATES.each do |template|
        level_stones = stones_of_color(BLACK).select{|x,y| y==@n+1-template.level}
        level_stones.each do |stone|
          x, y = stone
          if template.open.all?{|i,j| get_cell([x+i,y+j]) != WHITE} #Black or Empty
            if template.taken.all?{|i,j| get_cell([x+i,y+j]) == BLACK}
              connected_stones << stone
            end
          end
        end
      end
      connected_stones
    end
  end
end
