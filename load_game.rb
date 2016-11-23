require_relative 'display'

board = Board.new
board.set_initial_position
p board[[1, 5]]
display = Display.new(board)

display.move_cursor
