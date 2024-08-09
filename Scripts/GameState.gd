GameState.gd
4.96 KB • 182 extracted lines

Formatting may be inconsistent from source.

extends Node

enum StoneColor { NONE, BLACK, WHITE }

var current_turn = StoneColor.BLACK
var board_size = 9
var board_state = []
var groups = []
var group_liberties = {}

signal turn_changed
signal capture_started(stones_to_capture)
signal stone_captured(stone_index)
signal capture_finished

func _ready():
	initialize_board()

func initialize_board():
	board_state.clear()
	for i in range(board_size * board_size):
		board_state.append(StoneColor.NONE)

func switch_turn():
	current_turn = StoneColor.WHITE if current_turn == StoneColor.BLACK else StoneColor.BLACK
	emit_signal("turn_changed", current_turn)

func get_current_turn():
	return current_turn

func place_stone(index, color):
	board_state[index] = color
	update_groups_and_liberties()

func update_groups_and_liberties():
	groups.clear()
	group_liberties.clear()
	for i in range(board_size * board_size):
		if board_state[i] != StoneColor.NONE and not is_stone_in_group(i):
			create_group(i)

func is_stone_in_group(index):
	for group in groups:
		if index in group:
			return true
	return false

func create_group(start_index):
	var color = board_state[start_index]
	var group = [start_index]
	var to_check = [start_index]
	var liberties = []

	while to_check:
		var current = to_check.pop_back()
		var neighbors = get_neighbors(current)
		
		for neighbor in neighbors:
			if board_state[neighbor] == color and neighbor not in group:
				group.append(neighbor)
				to_check.append(neighbor)
			elif board_state[neighbor] == StoneColor.NONE and neighbor not in liberties:
				liberties.append(neighbor)

	groups.append(group)
	group_liberties[group[0]] = liberties

func is_move_valid(index):
	print("Checking move validity for index: ", index, " Current turn: ", StoneColor.keys()[current_turn])
	
	if board_state[index] != StoneColor.NONE:
		print("Invalid move: Space already occupied")
		return false
	
	# Check if the move would result in a stone with liberties
	var temp_board = board_state.duplicate()
	temp_board[index] = current_turn
	var temp_liberties = get_temp_liberties(index, temp_board)
	
	print("Temporary liberties: ", temp_liberties)
	
	if len(temp_liberties) > 0:
		print("Move is valid: Stone has liberties")
		return true
	
	if would_capture_opponent(index, temp_board):
		print("Move is valid: Would capture opponent")
		return true
	
	print("Invalid move: No liberties and no capture")
	return false

func get_temp_liberties(index, temp_board):
	var temp_liberties = []
	var neighbors = get_neighbors(index)
	
	for neighbor in neighbors:
		if temp_board[neighbor] == StoneColor.NONE:
			temp_liberties.append(neighbor)
	
	# Check if this stone connects to a friendly group with liberties
	var current_color = temp_board[index]
	for neighbor in neighbors:
		if temp_board[neighbor] == current_color:
			var group = get_connected_stones(neighbor, current_color, temp_board)
			group.append(index)  # Include the new stone in the group
			var connected_group_liberties = get_group_liberties(group, temp_board)
			temp_liberties.append_array(connected_group_liberties)
	
	# Remove duplicates
	return temp_liberties.duplicate()

func would_capture_opponent(index, temp_board):
	var neighbors = get_neighbors(index)
	var opponent_color = StoneColor.WHITE if current_turn == StoneColor.BLACK else StoneColor.BLACK
	
	for neighbor in neighbors:
		if temp_board[neighbor] == opponent_color:
			var group = get_connected_stones(neighbor, opponent_color, temp_board)
			var opponent_group_liberties = get_group_liberties(group, temp_board)
			print("Opponent group at ", neighbor, " has liberties: ", opponent_group_liberties)
			if opponent_group_liberties.is_empty():
				return true
	
	return false

func get_neighbors(index):
	var neighbors = []
	var row = index / board_size
	var col = index % board_size

	if row > 0:
		neighbors.append(index - board_size)
	if row < board_size - 1:
		neighbors.append(index + board_size)
	if col > 0:
		neighbors.append(index - 1)
	if col < board_size - 1:
		neighbors.append(index + 1)

	return neighbors

func get_stone_liberties(index):
	for group in groups:
		if index in group:
			return group_liberties[group[0]]
	return []

func get_connected_stones(start_index, color, temp_board):
	var group = [start_index]
	var to_check = [start_index]
	
	while to_check:
		var current = to_check.pop_back()
		var neighbors = get_neighbors(current)
		
		for neighbor in neighbors:
			if temp_board[neighbor] == color and neighbor not in group:
				group.append(neighbor)
				to_check.append(neighbor)
	
	return group

func get_group_liberties(group, temp_board):
	var liberties = []
	
	for stone in group:
		var neighbors = get_neighbors(stone)
		for neighbor in neighbors:
			if temp_board[neighbor] == StoneColor.NONE and neighbor not in liberties:
				liberties.append(neighbor)
	
	return liberties

func capture_stones(stones_to_capture):
	emit_signal("capture_started", stones_to_capture)
	for stone in stones_to_capture:
		board_state[stone] = StoneColor.NONE
		emit_signal("stone_captured", stone)
	update_groups_and_liberties()
	emit_signal("capture_finished")