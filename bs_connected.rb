module HexGraph
  class BoardState
    # Returns a list of stones connected to the stone at the
    # specified cell.  This connection assumes that two empty
    # cells between two stones allows a connection to be formed
    def connected_groups(starting_stones, starting_required = [])
      groups = [connected_stones(starting_stones)]
      color = get_cell(starting_stones.first)
      stones_of_color(color).each do |cell|
        next if groups.flatten(1).include?(cell)
        groups << connected_stones([cell])
      end
      base_group = groups[0]
      unmatched = groups[1..groups.size]
      required_open_groups = [starting_required]
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
