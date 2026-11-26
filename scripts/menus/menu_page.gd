extends Control

@onready var quit_game = $QuitGame

func _ready() -> void:
	quit_game.gui_input.connect(_on_quit_game_pressed)
	quit_game.move_to_front()
	
func _on_quit_game_pressed(event: InputEvent) -> void:
	if(event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT):
		get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
