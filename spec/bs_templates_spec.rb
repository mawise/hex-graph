require_relative '../hexgraph'
include HexGraph

describe BoardState, "" do
  it "finds a stone connected south by right 2-3-4 template" do
    bs = BoardState.new(4)
    bs.set_cell([3,2], BLACK)
    connected_south, needed = bs.template_connected("south")
    expect(connected_south).to include [3,2]
  end
  
  it "finds a stone connected south by left 2-3-4 template" do
    bs = BoardState.new(4)
    bs.set_cell([4,2], BLACK)
    connected_south, needed = bs.template_connected("south")
    expect(connected_south).to include [4,2]
  end

  it "doesn't find any stone not connected south by 2-3-4 template" do
    bs = BoardState.new(4)
    bs.set_cell([1,2], BLACK)
    connected_south, needed = bs.template_connected("south")
    expect(connected_south).to be_empty
  end
  
  it "finds a stone connected east by  2-3-4 template" do
    bs = BoardState.new(4)
    bs.set_cell([2,3], WHITE)
    connected, needed = bs.template_connected("east")
    expect(connected).to include [2,3]
  end

  it "finds a stone connected west by  2-3-4 template" do
    bs = BoardState.new(4)
    bs.set_cell([3,2], WHITE)
    connected, needed = bs.template_connected("west")
    expect(connected).to include [3,2]
  end
  
  it "finds a stone connected north by  2-3-4 template" do
    bs = BoardState.new(4)
    bs.set_cell([2,3], BLACK)
    connected, needed = bs.template_connected("north")
    expect(connected).to include [2,3]
  end
end
