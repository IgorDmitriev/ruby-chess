require_relative 'display'

board = Board.new
p board[[1, 5]]
display = Display.new(board)

display.move_cursor
