extends Control

@onready var play_button = $PlayButton
@onready var quit_button = $QuitButton
@onready var play_text = $PlayText
@onready var quit_text = $QuitText

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play_text.pressed.connect(_on_play_pressed)
	quit_text.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	
func _on_quit_pressed() -> void:
	get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
