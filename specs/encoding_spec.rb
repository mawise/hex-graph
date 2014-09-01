require_relative '../encoding'
include HexGraph

describe Encoding do
  it "converts a 3x3 full board" do
    board = "121 212 121".gsub(" ","")
    encoded = encode_32(board)
    decoded = decode_32(encoded, 3)
    expect(decoded).to eq(board)
  end
end
