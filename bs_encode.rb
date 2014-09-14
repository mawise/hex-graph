module HexGraph
  class BoardState

    def to_base_4
      str = ""
      (1..@n).each do |y|
        (1..@n).each do |x|
          str << (get_cell([x,y]) % 4).to_s
        end
      end
      str
    end

    def from_base_4(str)
      reset
      # 3 for Black, 1 for white, 0 for open.  One row at a time.
      raise "#{str} Wrong length state string for board size #{@n}" unless str.size == @n*@n
      @grid = Hash.new(EMPTY)
      set_edges
      i=0
      str.each_char do |ch|
        x = (i % @n) + 1
        y = (i / @n) + 1
        set_cell([x,y], WHITE) if ch=='1'  
        set_cell([x,y], BLACK) if ch=='3' 
        i+=1 
      end
    end
       
    def to_i
      to_base_4.to_i(4)
    end
    def from_i(i)
      from_base_4(i.to_s(4).rjust(@n*@n,"0"))
    end  
  end
end
