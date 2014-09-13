Hex Graph
=========

Framework for eventually building an AI to play the game [Hex](http://en.wikipedia.org/wiki/Hex_(board_game)).  

Try it out
----------
* Look at the specs to get an idea of how to interface with the library
* Copy `runner.rb` as a starting point to play around with it

API (v0.itwillchange)
---------------------

Create a new empty `BoardState` for a 3 x 3 grid:

```ruby
include HexGraph # Bring the module into the local namespace
bs = BoardState.new(3)
```

Populate the board.  `O` for open, `B` for black, `W` for white.  Fill out the board one row at a time, spaces get ignored so you can use them to help visually see what you're building.  Black runs North-South.  White runs East-West.  The first cell in the second row connects to the first two cells in the top row (North-West is an acute corner).

```ruby
bs.populate_string("OBO WOO OOO")
```

Make a move.  The North-West corner is `[1,1]`.  The first index is the column, the second index is the row.

```ruby
bs.set_cell([2,2], WHITE) # This is HexGraph::WHITE
```

Look at the board as-is.

```ruby
bs.print_board
```

See if black has obviously won (white to move).

```ruby
puts "Black has #{bs.black_wins? ? "" : "not "}won"
```

Search the game tree to see if black is in a winning state (white to move).  Note, this is impossibly slow on large (> 4x4) boards.  

```ruby
puts "Black has #{bs.black_wins_recursive? ? "" : "not "}won"
```

Status
------
* Solves 3x3 in about 1/10 second.
* Solves 4x4 in about 2 minutes.


