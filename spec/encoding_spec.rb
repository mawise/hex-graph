require_relative '../board_state'
include HexGraph

describe Encoding do
  it "converts a 3x3 full board" do
    board = "131 313 131".gsub(" ","")
    bs = BoardState.new(3)
    bs.from_base_4(board)
    decoded = bs.to_base_4
    expect(decoded).to eq(board)
  end

  it "uses ints to marshal a board" do
    bs = BoardState.new(3)
    bs.set_cell([3,2],BLACK)
    num = bs.to_i
    b2 = BoardState.new(3)
    b2.from_i(num)
    expect(b2.get_cell([3,2])).to eq BLACK
    expect(b2.get_cell([1,1])).to eq EMPTY
  end
end
