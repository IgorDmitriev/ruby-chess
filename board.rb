require_relative 'piece'
require 'byebug'
class Board
  attr_reader :grid

  def initialize(grid = nil)
    @grid = grid ? grid : Array.new(8) { Array.new(8) { NullPiece.instance } }
  end

  def move_piece(start_pos, end_pos, force = false)
    unless force
      unless self[start_pos] && valid_pos?(start_pos)
        raise 'Starting position is invalid'
      end
      # self[end_pos].color != turn_color
      unless (self[end_pos].color == :red || self[end_pos].color != self[start_pos].color) && valid_pos?(end_pos)
        raise 'Ending position is invalid'
      end

      p self[start_pos].moves
      unless self[start_pos].really_valid_moves.include?(end_pos)
        raise 'Can not move there!'
      end
    end

    self[end_pos], self[start_pos] = self[start_pos], NullPiece.instance
    self[end_pos].position = end_pos
    # if in_check?(self[end_pos].enemy_color)
    #   puts "CHECK"
    #   sleep 3
    # end
    self
  end

  def in_check?(color)
    # debugger
    king = find_pieces(color, :king).first
    all_pieces_moves(king.enemy_color).include?(king.position)
  end

  def checkmate?(color)
    find_pieces(color).all? do |piece|
      piece.really_valid_moves.empty?
    end
  end

  def all_pieces_moves(color)
    enemy_pieces = find_pieces(color)

    all_moves = []
    enemy_pieces.each do |piece|
      all_moves += piece.moves
    end
    all_moves
  end

  def find_pieces(color, type = :all)
    pieces = []
    grid.each do |row|
      row.each do |piece|
        if piece.color == color
          case type
          when :all, piece.symbol then pieces << piece
          end
        end
      end
    end
    pieces
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

  WHITE_POSITIONS = {
    pawn: [[1, 0], [1, 1], [1, 2], [1, 3], [1, 4], [1, 5], [1, 6], [1, 7]],
    rook: [[0, 0], [0, 7]],
    knight: [[0, 1], [0, 6]],
    bishop: [[0, 2], [0, 5]],
    king: [[0, 3]],
    queen: [[0, 4]]
  }.freeze

  BLACK_POSITIONS = {
    pawn: [[6, 0], [6, 1], [6, 2], [6, 3], [6, 4], [6, 5], [6, 6], [6, 7]],
    rook: [[7, 0], [7, 7]],
    knight: [[7, 1], [7, 6]],
    bishop: [[7, 2], [7, 5]],
    king: [[7, 3]],
    queen: [[7, 4]]
  }.freeze

  def set_white_pieces
    WHITE_POSITIONS.each do |type, positions|
      positions.each { |pos| set_a_piece(type, :white, pos) }
    end
  end

  def set_black_pieces
    BLACK_POSITIONS.each do |type, positions|
      positions.each { |pos| set_a_piece(type, :black, pos) }
    end
  end

  def set_a_piece(type, color, pos)
    self[pos] = case type
                when :pawn then Pawn.new(color, self, pos)
                when :rook then Rook.new(color, self, pos)
                when :knight then Knight.new(color, self, pos)
                when :bishop then Bishop.new(color, self, pos)
                when :king then King.new(color, self, pos)
                when :queen then Queen.new(color, self, pos)
                end
  end

  def dup
    dupped_board = Board.new
    (0..7).each do |row_idx|
      (0..7).each do |col_idx|
        piece = self[[row_idx, col_idx]]
        next if piece.is_a?(NullPiece)
        dupped_board.set_a_piece(piece.symbol, piece.color, piece.position)
        # piece.is_a?(NullPiece) ? NullPiece.instance : piece.dup
      end
    end

    dupped_board
  end
end
