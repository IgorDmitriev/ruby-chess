require_relative 'piece'

class Board
  attr_reader :grid

  def initialize
    @grid = Array.new(8) { Array.new(8) { NullPiece.instance } }
    # @move_pos = []
    set_initial_position
  end

  # def next_move(pos)
  #   move_pos << pos
  #   move_piece(move_pos[0], move_pos[1]) if move_pos.size == 2
  # end

  def move_piece(start_pos, end_pos)
    #  self[start_pos].color == turn_color
    unless self[start_pos] && valid_pos?(start_pos)
      raise 'Starting position is invalid'
    end
    # self[end_pos].color != turn_color
    unless (self[end_pos].color == :red || self[end_pos].color != self[start_pos].color) && valid_pos?(end_pos)
      raise 'Ending position is invalid'
    end

    p self[start_pos].moves
    unless self[start_pos].moves.include?(end_pos)
      raise 'Can not move there!'
    end

    self[end_pos], self[start_pos] = self[start_pos], NullPiece.instance
    self[end_pos].position = end_pos
    # @move_pos = []
  end

  def valid_pos?(pos)
    row, col = pos
    row.between?(0, 7) && col.between?(0, 7)
  end

  def [](pos)
    row, col = pos
    @grid[row][col]
  end

  def []=(pos, value)
    row, col = pos
    @grid[row][col] = value
  end

  def set_initial_position
    set_white_pieces
    set_black_pieces
  end

  def set_white_pieces
    (0..1).each do |row|
      (0..7).each do |col|
        grid[row][col] = Bishop.new(:white, self, [row, col])
      end
    end
  end

  def set_black_pieces
    (6..7).each do |row|
      (0..7).each do |col|
        grid[row][col] = Piece.new(:black, self, [row, col])
      end
    end
  end
end
