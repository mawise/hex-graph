require_relative 'hexgraph'
include HexGraph

#WHITE = HexGraph::WHITE
#BLACK = HexGraph::BLACK
#EMPTY = HexGraph::EMPTY

raise("must pass a board-size argument") unless ARGV.size == 1

n = ARGV.shift.to_i
black_opens = BoardState.new(n)

start = Time.now
black_opens.stones_of_color(EMPTY).each do |move|
  x,y = move
  next if y-1 > (n-1)/2
  bs = BoardState.new(n)
  bs.set_cell(move, BLACK)
  if bs.black_wins_recursive?
    black_opens.set_cell(move, BLACK)
  else
    black_opens.set_cell(move, WHITE)
  end
  puts "#{black_opens.get_cell(move)==BLACK ? "Black" : "White"} wins with Black open at #{move}"
end
black_opens.stones_of_color(EMPTY).each do |move|
  x,y = move.map{|i| i-1}
  black_opens.set_cell(move, black_opens.get_cell([n-x, n-y]))
end


puts "Runtime: #{Time.now - start}"
puts "Winner if black opens:"
black_opens.print_board

