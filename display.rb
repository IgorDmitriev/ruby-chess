require 'colorize'
require_relative 'board'
require_relative 'cursor'
require 'byebug'

class Display
  attr_reader :board, :cursor

  def initialize(board)
    @board = board
    @cursor = Cursor.new([0,0], board)
  end

  def render
    # debugger
    print '  '
    puts (0..7).to_a.join(' ')
    (0..7).each do |row|
      print "#{row} "
      (0..7).each do |col|
        piece = board[[row, col]]
        current_color = if [row, col] == cursor.cursor_pos
                          cursor.color
                        else
                          piece.color
                        end
        print '  '.colorize(background: current_color)
      end
      puts ''
    end
  end

  def move_cursor
    loop do
      move = []
      while move.size < 2
        system 'clear'
        render
        pos = cursor.get_input
        if pos
          move << pos
        end
      end
      board.move_piece(move[0], move[1])
    end
  rescue => e
    puts e.message
    sleep 1
    retry
  end

end
