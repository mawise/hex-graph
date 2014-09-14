require_relative '../hexgraph'
include HexGraph

describe Template, "" do
  it "produces a south-edge form" do
    t = TEMPLATES.first
    expect(t.south).to be t
  end

end
