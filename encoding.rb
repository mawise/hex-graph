module HexGraph
  def encode_32(base_4_string)
    # base_4_string is base 4 representation of board.
    #   0 is empty, 1 is white, 2 is black
    base_4_string.to_i(4).to_s(32)
  end

  def decode_32(base_32_string, n)
    base_32_string.to_i(32).to_s(4) # need leading 0s to make nxn characters
  end
end
