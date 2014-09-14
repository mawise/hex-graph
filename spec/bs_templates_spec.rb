require_relative '../hexgraph'
include HexGraph

describe BoardState, "" do
  it "finds a stone connected south by right 2-3-4 template" do
    bs = BoardState.new(4)
    bs.set_cell([3,2], BLACK)
    connected_south = bs.template_connected_south
    expect(connected_south).to include [3,2]
  end
  
  it "finds a stone connected south by left 2-3-4 template" do
    bs = BoardState.new(4)
    bs.set_cell([4,2], BLACK)
    connected_south = bs.template_connected_south
    expect(connected_south).to include [4,2]
  end

  it "finds a stone not connected south by 2-3-4 template" do
    bs = BoardState.new(4)
    bs.set_cell([1,2], BLACK)
    connected_south = bs.template_connected_south
    expect(connected_south).to be_empty
  end
end
