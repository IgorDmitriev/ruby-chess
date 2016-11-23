require 'singleton'

class Piece
  attr_reader :color, :board, :symbol
  attr_accessor :position

  def initialize(color, board, position)
    @color = color
    @board = board
    @position = position
  end

  def enemy_color
    @color == :white ? :black : :white
  end

  def to_s
    case symbol
    when :pawn then '♙ '
    when :rook then '♖ '
    when :knight then '♘ '
    when :bishop then '♗ '
    when :king then '♔ '
    when :queen then '♕ '
    when :null then '  '
    end
  end

  def moves
    []
  end

  def really_valid_moves
    moves.reject do |move|
      move_into_check?(move)
    end
  end

  def move_into_check?(end_pos)
    dup_board = board.dup
    potential_board = dup_board.move_piece(position, end_pos, true)
    Display.new(potential_board).render
    potential_board.in_check?(color)
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

  def moves
    all_moves = move_diffs.map do |dx, dy|
      row, col = position
      [row + dx, col + dy]
    end
    in_board_moves = all_moves.select { |move| board.valid_pos?(move) }
    valid_moves = in_board_moves.reject { |move| board[move].color == self.color }
    valid_moves
  end

end

class Bishop < Piece
  include SlidingPiece

  def initialize(color, board, pos)
    super
  end

  def move_dirs
    [:diagonal]
  end

  def symbol
    :bishop
  end
end

class Rook < Piece
  include SlidingPiece

  def initialize(color, board, pos)
    super
  end

  def move_dirs
    [:horizontal, :vertical]
  end

  def symbol
    :rook
  end
end

class Queen < Piece
  include SlidingPiece

  def initialize(color, board, pos)
    super
  end

  def move_dirs
    [:diagonal, :horizontal, :vertical]
  end

  def symbol
    :queen
  end
end

class NullPiece < Piece
  include Singleton

  def initialize
    @symbol = :null
  end

  def color
    :red
  end

end

class King < Piece
  include SteppingPiece

  def initialize(color, board, pos)
    super
  end

  def move_diffs
    [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]]
  end

  def symbol
    :king
  end
end

class Knight < Piece
  include SteppingPiece

  def initialize(color, board, pos)
    super
  end

  def move_diffs
    [[-2, 1], [-1, 2], [1, 2], [2, 1], [2, -1], [1, -2], [-1, -2], [-2, -1]]
  end

  def symbol
    :knight
  end
end

class Pawn < Piece

  def initialize(color, board, position)
    @starting_pos = position
    super
  end

  def symbol
    :pawn
  end

  def moves
    valid_moves = []
    row, col = position
    next_pos = [row + forward_dir, col]
    if board[next_pos].is_a?(NullPiece)
      valid_moves << next_pos
      next_next_pos = [row + 2 * forward_dir, col]
      if at_start_pos? && board[next_next_pos].is_a?(NullPiece)
        valid_moves << next_next_pos
      end
    end
    valid_moves += side_attacks.select do |move|
      board.valid_pos?(move) && board[move].color == self.enemy_color
    end
    valid_moves
  end

  def at_start_pos?
    self.position == @starting_pos
  end

  def forward_dir
    self.color == :white ? 1 : -1
  end

  def side_attacks
    row, col = position
    [[row + forward_dir, col + 1], [row + forward_dir, col - 1]]
  end

end
