require_relative '../board_state'
include HexGraph

describe BoardState, "" do
  it "black does not win on an empty board" do
    bs = BoardState.new(4)
    expect(bs.black_wins?).to be false
  end

  it "cells are adjacent to 6 cells" do
    (3..6).each do |n|
      bs = BoardState.new(n)
      (1..n).each do |x|
        (1..n).each do |y|
          expect(bs.adjacent_to([x,y]).size).to eq(6)
        end
      end
    end
  end 

  it "correctly counts open_adjacent_to_group cells" do
    bs = BoardState.new(4)
    bs.populate_string("OOOO OBBO OOOO OOOO")
    group = bs.connected_stones([[2,2]])
    open_adj = bs.open_adjacent_to_group(group)
    expect(open_adj.size).to eq(8) 
    [[2,1],[3,1],[1,2],[3,3]].each do |cell|
      expect(open_adj).to include(cell)
    end
    expect(open_adj.include?([3,2])).to be false #part of the group
  end

  it "black naive algorithm works" do
    bs = BoardState.new(3)
    bs.populate_string("WWB WWB WWB")
    expect(bs.black_wins_naive?).to be true
  end

  it "black wins with a skip" do
    bs = BoardState.new(3)
    bs.populate_string("WBW OOW BWW")
    expect(bs.black_wins?).to be true
  end

  it "black wins with a skip to the edge" do
    bs = BoardState.new(3)
    bs.populate_string("BBB BBB OOO")
    expect(bs.black_wins?).to be true
  end
 
  it "left edge connected to left" do
    (1..5).each do |n|
      (1..n).each do |y|
        bs = BoardState.new(n)
        bs.set_cell([1,y], WHITE)
        expect(bs.connected_stones([[1,y]])).to include [0,1]
      end
    end
  end

#  it "overlap skips do not win" do
#    bs = BoardState.new(4)
#    bs.populate_string("OBWW OOBO BOOB WWOO")
#    # White wins at 2,2
#    expect(bs.black_wins?).to be false
#  end
  
end
