extends Node

var has_journal = false

@onready var world = $World
@onready var top_bar = $UI/TopBar
@onready var journal = $UI/Journal
@onready var fade = $Overlay/Fade
#@onready var wake_up_label = $Overlay/WakeUpLabel
@onready var montage_video_player = $Overlay/MontageVideoPlayer


func _ready():
	journal.hide()
	top_bar.set_day(1)
	montage_video_player.hide()
	top_bar.journal_button_pressed.connect(on_journal_button_pressed)
	start_game()


func start_game():
	fade.set_black()
	#wake_up_label.show()
	# placeholder for the waking up montage
	await get_tree().create_timer(2.0).timeout
	#wake_up_label.hide()
	load_room("res://scenes/world/bedroom.tscn")
	await fade.fade_in(1.0)


# puts a room into World, and removes the old one
func load_room(path):
	for child in world.get_children():
		world.remove_child(child)
		child.queue_free()
	var room = load(path).instantiate()
	world.add_child(room)
	# rooms that have a journal to pick up tell us when it happens
	if room.has_signal("journal_picked_up"):
		room.journal_picked_up.connect(on_journal_picked_up)


func on_journal_picked_up():
	has_journal = true
	top_bar.show_journal_button()


func on_journal_button_pressed():
	journal.open()
