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
  
  it "makes new objects when cloning" do
    bs = BoardState.new(2)
    bs.populate_string("OO BW")
    bs2 = bs.clone
    cell = [1,1]
    bs2.set_cell(cell, BLACK)
    expect(bs2.get_cell(cell)).to eq(BLACK)
    expect(bs.get_cell(cell)).to eq(EMPTY)
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

  it "has a functioning connected_groups method" do
    bs = BoardState.new(3)
    bs.populate_string("OOB OOO OBO")
    top_stone = [1,0]
    connected, required = bs.connected_groups(top_stone)
    expect(connected).to include [3,1]
    expect(connected).to include [2,3]
    expect(required).to include [3,2]
    expect(required).to include [2,2]
  end

  it "reclaculates win after a reset" do
    bs = BoardState.new(3)
    bs.populate_string("OOB OOO OBO")
    expect(bs.black_wins?).to be true
    expect(bs.black_wins?).to be true
    bs.reset
    expect(bs.black_wins?).to be true
  end

  it "keeps track of required cells" do
    bs = BoardState.new(3)
    bs.populate_string("OOB OOO OBO")
    expect(bs.black_required).to include [3,2]
    expect(bs.black_required).to include [2,2]
  end

  it "overlap skips do not win" do
    bs = BoardState.new(4)
    bs.populate_string("OBWW OOBO BOOB WWOO")
    # White wins at 2,2
    expect(bs.black_wins?).to be false
    bs.set_cell([2,2],WHITE)
    expect(bs.white_wins?).to be true
  end
 

  it "finds a unique win move" do
    bs = BoardState.new(4)
    bs.populate_string("OBWW OOBO BOOB WWOO")
    #TODO: white to move, plays at [2,2] 
  end

  it "doesn't include corners in set of empty stones" do
    n = 2
    bs = BoardState.new(n)
    empty = bs.stones_of_color(EMPTY)
    corners = [[0,0],[0,n+1],[n+1,n+1],[n+1,0]]
    expect(empty & corners).to be_empty
  end

  it "3-3 overlap skips still win" do
    bs = BoardState.new(6)
    bs.populate_string("WBBWWO BOOBOO OBOBOW WOBWOO BOWOOO BWOOOW")
    expect(bs.black_wins?).to be true
  end
  
  it "doesn't win with acute corner opening on 3x3" do
    bs = BoardState.new(3)
    corner = [1,1]
    bs.set_cell(corner, BLACK)
    expect(bs.black_wins?).to be false
    expect(bs.black_wins_recursive?).to be false
    bs.set_cell(corner, WHITE)
    expect(bs.white_wins?).to be false
    expect(bs.white_wins_recursive?).to be false
  end

  it "correctly builds the must_play" do
    bs = BoardState.new(4)
    open = [1,2]
    bs.set_cell(open,BLACK)
    expect(bs.must_play(BLACK)).to include [2,3]
  end

  it "wins on center response to acute corner" do
    bs = BoardState.new(3)
    corner = [1,1]
    center = [2,2]
    bs.set_cell(corner, BLACK)
    bs.set_cell(center, WHITE)
    expect(bs.white_wins?).to be true
  end
end
