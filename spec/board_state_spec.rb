require_relative '../hexgraph'
include HexGraph


# These are tests that deal with building a particular board
# and checking that the correct player wins.
describe BoardState, "" do
  it "black does not win on an empty board" do
    bs = BoardState.new(4)
    expect(bs.black_wins?).to be false
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
 
  it "overlap skips do not win" do
    bs = BoardState.new(4)
    bs.populate_string("OBWW OOBO BOOB WWOO")
    # White wins at 2,2
    expect(bs.black_wins?).to be false
    bs.set_cell([2,2],WHITE)
    expect(bs.white_wins?).to be true
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

  it "wins on center response to acute corner" do
    bs = BoardState.new(3)
    corner = [1,1]
    center = [2,2]
    bs.set_cell(corner, BLACK)
    bs.set_cell(center, WHITE)
    expect(bs.white_wins?).to be true
  end
end
