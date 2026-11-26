extends Control

@onready var credits = $RichTextLabel
@export var scroll_speed: float = 60.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	credits.position.y -= scroll_speed * delta
	if(Input.is_key_pressed(KEY_SPACE)):
		credits.position.y -= scroll_speed * delta
		credits.position.y -= scroll_speed * delta
	if(credits.position.y + credits.size.y < 0):
		get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if(event.is_action_pressed("ui_cancel")):
		get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
		
