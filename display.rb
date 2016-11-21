require 'colorize'
require_relative 'board'
require_relative 'cursor'

class Display
  attr_reader :board, :cursor

  def initialize(board)
    @board = board
    @cursor = Cursor.new([0,0], board)
  end

  def render
    cursor_color = :blue
    current_color = nil
    (0..7).each do |row|
      (0..7).each do |col|
        spot = board[[row, col]]
        current_color = if [row, col] == cursor.cursor_pos
                          cursor_color
                        else
                          spot ? spot.color : :red
                        end
        print '  '.colorize(background: current_color)
      end
      puts ''
    end
  end

  def move_cursor
    while true
      system 'clear'
      render
      cursor.get_input
    end
  end

end
