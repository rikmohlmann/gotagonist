#InstantiateSprites.gd

extends GridContainer

var corner_topleft_scene = preload("res://Scenes/CornerTopLeft.tscn")
var corner_topright_scene = preload("res://Scenes/CornerTopRight.tscn")
var corner_bottomleft_scene = preload("res://Scenes/CornerBottomLeft.tscn")
var corner_bottomright_scene = preload("res://Scenes/CornerBottomRight.tscn")
var edge_top_scene = preload("res://Scenes/EdgeTop.tscn")
var edge_bottom_scene = preload("res://Scenes/EdgeBottom.tscn")
var edge_left_scene = preload("res://Scenes/EdgeLeft.tscn")
var edge_right_scene = preload("res://Scenes/EdgeRight.tscn")
var normal_scene = preload("res://Scenes/CenterButton.tscn")
var star_point_scene = preload("res://Scenes/StarPointButton.tscn")

var grid_columns = 9
var grid_rows = 9
var board_state = []
var capture_timer: Timer
var stones_to_capture: Array
var star_points = [20, 24, 40, 56, 60]

func _ready():
	columns = GameState.board_size
	GameState.initialize_board()
	_create_board()
	SoundManager.play_background_music()
	
	# Connect to GameState signals
	GameState.connect("capture_started", Callable(self, "_on_capture_started"))
	GameState.connect("stone_captured", Callable(self, "_on_stone_captured"))
	
	# Create and set up the capture timer
	capture_timer = Timer.new()
	capture_timer.one_shot = false
	capture_timer.connect("timeout", Callable(self, "_on_capture_timer_timeout"))
	add_child(capture_timer)

func _create_board():
	for i in range(grid_rows * grid_columns):
		var row = i / grid_columns
		var col = i % grid_columns

		var square = _get_appropriate_square(row, col)
		square.name = "Square_" + str(i)
		square.pressed.connect(_on_square_pressed.bind(i))
		
		square.custom_minimum_size = Vector2(64, 64)
		square.size = Vector2(64, 64)
		
		add_child(square)

func _get_appropriate_square(row, col):
	var index = row * grid_columns + col
	
	if index in star_points:
		return star_point_scene.instantiate()
	
	if row == 0 and col == 0:
		return corner_topleft_scene.instantiate()
	elif row == 0 and col == grid_columns - 1:
		return corner_topright_scene.instantiate()
	elif row == grid_rows - 1 and col == 0:
		return corner_bottomleft_scene.instantiate()
	elif row == grid_rows - 1 and col == grid_columns - 1:
		return corner_bottomright_scene.instantiate()
	elif row == 0:
		return edge_top_scene.instantiate()
	elif row == grid_rows - 1:
		return edge_bottom_scene.instantiate()
	elif col == 0:
		return edge_left_scene.instantiate()
	elif col == grid_columns - 1:
		return edge_right_scene.instantiate()
	else:
		return normal_scene.instantiate()

func _on_square_pressed(square_index):
	if GameState.is_move_valid(square_index):
		GameState.place_stone(square_index, GameState.get_current_turn())
		var square = get_node("Square_" + str(square_index))
		square.set_stone_color(GameState.get_current_turn())
		
		# Check for captures
		var opponent_color = GameState.StoneColor.WHITE if GameState.get_current_turn() == GameState.StoneColor.BLACK else GameState.StoneColor.BLACK
		var neighbors = GameState.get_neighbors(square_index)
		stones_to_capture.clear()
		
		for neighbor in neighbors:
			if GameState.board_state[neighbor] == opponent_color:
				var group = GameState.get_connected_stones(neighbor, opponent_color, GameState.board_state)
				if GameState.get_group_liberties(group, GameState.board_state).is_empty():
					stones_to_capture.append_array(group)
		
		if not stones_to_capture.is_empty():
			_start_capture_sequence()
		else:
			GameState.switch_turn()
		
		print("Stone placed at ", square_index, " Color: ", GameState.StoneColor.keys()[GameState.get_current_turn()])
	else:
		print("Invalid move")

func _start_capture_sequence():
	if not stones_to_capture.is_empty():
		capture_timer.start(0.1)  # Adjust this value to change the interval between captures
	else:
		GameState.switch_turn()

func _on_capture_timer_timeout():
	if not stones_to_capture.is_empty():
		var stone_index = stones_to_capture.pop_front()
		_capture_stone(stone_index)
	else:
		capture_timer.stop()
		GameState.switch_turn()

func _capture_stone(stone_index):
	var captured_square = get_node("Square_" + str(stone_index))
	captured_square.capture_stone()
	SoundManager.play_capture_sound()
	GameState.board_state[stone_index] = GameState.StoneColor.NONE

func update_board_visuals():
	for i in range(GameState.board_size * GameState.board_size):
		var square = get_node("Square_" + str(i))
		square.set_stone_color(GameState.board_state[i])