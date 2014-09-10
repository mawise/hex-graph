require_relative 'board_state'
include HexGraph

#WHITE = HexGraph::WHITE
#BLACK = HexGraph::BLACK
#EMPTY = HexGraph::EMPTY

n = 4
black_opens = BoardState.new(n)

start = Time.now
black_opens.stones_of_color(EMPTY).each do |move|
  bs = BoardState.new(n)
  bs.set_cell(move, BLACK)
  if bs.black_wins_recursive?
    black_opens.set_cell(move, BLACK)
  else
    black_opens.set_cell(move, WHITE)
  end
  puts "#{black_opens.get_cell(move)} wins at #{move}"
end

puts "Runtime: #{Time.now - start}"
puts "Winner if black opens:"
black_opens.print_board

