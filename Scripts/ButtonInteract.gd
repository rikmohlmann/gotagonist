ButtonInteraction.gd
1.52 KB • 56 extracted lines

Formatting may be inconsistent from source.

extends TextureButton

var is_hovering = false
var stone_color = GameState.StoneColor.NONE

@onready var anim_sprite = $AnimatedSprite2D

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_button_pressed)

func _exit_tree():
	if mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.disconnect(_on_mouse_entered)
	if mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.disconnect(_on_mouse_exited)
	if pressed.is_connected(_on_button_pressed):
		pressed.disconnect(_on_button_pressed)

func _on_mouse_entered():
	is_hovering = true
	if stone_color == GameState.StoneColor.NONE:
		SoundManager.play_empty_hover_sound()
	else:
		SoundManager.play_stone_hover_sound()
	if is_instance_valid(anim_sprite):
		anim_sprite.play_hover(stone_color)

func _on_mouse_exited():
	is_hovering = false
	if is_instance_valid(anim_sprite):
		anim_sprite.stop_hover()  # Remove the stone_color argument 

func _on_button_pressed():
	if stone_color == GameState.StoneColor.NONE and is_instance_valid(anim_sprite):
		anim_sprite.play_clicked()

func capture_stone():
	if is_instance_valid(anim_sprite):
		anim_sprite.play_captured()
	stone_color = GameState.StoneColor.NONE
	SoundManager.play_capture_sound()

func is_stone_placed():
	return stone_color != GameState.StoneColor.NONE

func set_stone_color(color):
	stone_color = color
	if is_instance_valid(anim_sprite):
		anim_sprite.set_stone_color(color)
	SoundManager.play_placement_sound()

func get_stone_color():
	return stone_color