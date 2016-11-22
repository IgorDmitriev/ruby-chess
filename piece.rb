require 'singleton'

class Piece
  attr_reader :color, :board
  attr_accessor :position

  def initialize(color, board, position)
    @color = color
    @board = board
    @position = position
  end
end

module SlidingPiece
  def moves
    valid_moves = []
    move_dirs.each do |move_dir|
      case move_dir
      when :diagonal
        diagonal_dirs.each do |dx, dy|
          valid_moves += grow_unblocked_moves_in_dirs(position, dx, dy)
        end
      when :horizontal
        horizontal_dirs.each do |dx, dy|
          valid_moves += grow_unblocked_moves_in_dirs(position, dx, dy)
        end
      when :vertical
        vertical_dirs.each do |dx, dy|
          valid_moves += grow_unblocked_moves_in_dirs(position, dx, dy)
        end
      end
    end
    valid_moves
  end

  def vertical_dirs
    [[1, 0], [-1, 0]]
  end

  def horizontal_dirs
    [[0, 1], [0, -1]]
  end

  def diagonal_dirs
    [[-1, -1], [1, 1], [1, -1], [-1, 1]]
  end

  def grow_unblocked_moves_in_dirs(pos, dx, dy)
    row, col = pos
    next_pos = [row + dx, col + dy]
    return [] unless board.valid_pos?(next_pos)
    return [] if board[next_pos].color == self.color
    return [next_pos] if board[next_pos].color == :black

    [next_pos] + grow_unblocked_moves_in_dirs(next_pos, dx, dy)
  end
end

module SteppingPiece
end

class Bishop < Piece
  include SlidingPiece

  # def initialize
  #   @symbol = ''
  # end
  def initialize(color, board, pos)
    super
  end

  def move_dirs
    [:diagonal]
  end
end

class Rook < Piece
  include SlidingPiece

  def move_dirs
    [:horizontal, :vertical]
  end
end

class Queen < Piece
  include SlidingPiece

  def move_dirs
    [:diagonal, :horizontal, :vertical]
  end
end

class NullPiece < Piece
  include Singleton

  # def initialize
  #   super(:red, '', [])
  # end
  def initialize
  end

  def color
    :red
  end

end
