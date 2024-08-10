
#AnimationControl.gd

extends AnimatedSprite2D

var stone_color = GameState.StoneColor.NONE
var current_state = "idle"
var target_state = "idle"

func _ready():
	play("empty_idle")
	print("Initial state: empty_idle")

func play_clicked():
	print("play_clicked function called")
	current_state = "clicked"
	target_state = "idle"  # Set target_state to "idle" immediately
	
	if stone_color == GameState.StoneColor.NONE:
		var current_turn = GameState.get_current_turn()
		var placement_animation = "white_placement" if current_turn == GameState.StoneColor.WHITE else "black_placement"
		play(placement_animation)
		await animation_finished
		_switch_to_idle()  # Switch to idle immediately after animation finishes

func play_hover(color):
	print("play_hover called, stone_color:", stone_color)
	target_state = "hover"
	if current_state == "idle":
		var hover_animation = _get_hover_animation(color)
		play(hover_animation)
		sprite_frames.set_animation_loop(hover_animation, false)
		current_state = "hover"

func stop_hover():
	print("stop_hover called")
	target_state = "idle"
	if current_state == "hover":
		if not is_playing():
			_switch_to_idle()
		else:
			# Let the current animation finish
			await animation_finished
			if target_state == "idle":
				_switch_to_idle()

func _switch_to_idle():
	print("Switching to idle state, stone_color:", stone_color)
	current_state = "idle"
	if stone_color == GameState.StoneColor.NONE:
		play("empty_idle")
	else:
		play(_get_idle_animation())

func play_captured():
	print("Stone captured")
	play(_get_capture_animation())
	await animation_finished
	stone_color = GameState.StoneColor.NONE
	_switch_to_idle()

func _on_animation_finished():
	print("Animation finished, current_state:", current_state, ", target_state:", target_state)
	if current_state == "hover" and target_state == "idle":
		_switch_to_idle()
	elif target_state == "idle" and current_state != "idle":
		_switch_to_idle()

func set_stone_color(color):
	stone_color = color
	_switch_to_idle()

func _get_idle_animation():
	match stone_color:
		GameState.StoneColor.NONE:
			return "empty_idle"
		GameState.StoneColor.BLACK:
			return "black_idle"
		GameState.StoneColor.WHITE:
			return "white_idle"

func _get_hover_animation(color):
	match color:
		GameState.StoneColor.NONE:
			return "empty_hover"
		GameState.StoneColor.BLACK:
			return "black_hover"
		GameState.StoneColor.WHITE:
			return "white_hover"

func _get_capture_animation():
	match stone_color:
		GameState.StoneColor.BLACK:
			return "black_capture"
		GameState.StoneColor.WHITE:
			return "white_capture"
		_:
			return "empty_idle"  # This shouldn't happen, but just in case