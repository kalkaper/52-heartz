extends Node

var bedroom_path = "res://scenes/world/bedroom.tscn"
var busy = false

@onready var world = $World
@onready var top_bar = $UI/TopBar
@onready var journal = $UI/Journal
@onready var hint_label = $UI/HintLabel
@onready var fade = $Overlay/Fade
@onready var montage = $Overlay/MontageVideoPlayer
@onready var old_wake_label = $Overlay/WakeUpLabel   # unused now, the montage replaces it


func _ready():
	journal.hide()
	hint_label.hide()
	old_wake_label.hide()
	top_bar.set_day(GameState.day)
	if GameState.has_journal:
		top_bar.show_journal_button()
	top_bar.journal_button_pressed.connect(on_journal_button_pressed)
	journal.day_ended.connect(on_day_ended)
	journal.dock_chosen.connect(on_dock_chosen)
	journal.radio_finished.connect(on_radio_finished)
	start_game()


func start_game():
	busy = true
	fade.set_black()
	await montage.play(Story.get_day(GameState.loop, GameState.day)["wake"])
	load_room(bedroom_path)
	await fade.fade_in(1.0)
	busy = false


func show_hint(text):
	hint_label.text = text
	hint_label.show()
	await get_tree().create_timer(2.0).timeout
	hint_label.hide()


func load_room(path):
	GameState.current_room = path
	for child in world.get_children():
		world.remove_child(child)
		child.queue_free()
	var room = load(path).instantiate()
	world.add_child(room)
	room.room_change_requested.connect(on_room_change_requested)
	if room.has_signal("journal_picked_up"):
		room.journal_picked_up.connect(on_journal_picked_up)
		if GameState.has_journal:
			room.hide_journal_spot()
	if room.has_signal("sleep_requested"):
		room.sleep_requested.connect(on_sleep_requested)


func on_room_change_requested(path):
	if busy:
		return
	busy = true
	await fade.fade_out(0.4)
	load_room(path)
	await fade.fade_in(0.4)
	await check_arrival_event(path)
	busy = false


# first time she enters the radio room on some days, something happens (day 2 headache)
func check_arrival_event(path):
	if path != Story.RADIO_ROOM:
		return
	var data = Story.get_day(GameState.loop, GameState.day)
	if data["arrival_event"].size() == 0 or GameState.day_flags.has("arrival_done"):
		return
	GameState.day_flags["arrival_done"] = true
	await fade.fade_out(0.6)
	await montage.play(data["arrival_event"])
	await fade.fade_in(1.0)


func on_journal_picked_up():
	GameState.has_journal = true
	top_bar.show_journal_button()


func on_journal_button_pressed():
	if busy:
		return
	journal.open()


func on_sleep_requested():
	if busy:
		return
	if not journal.all_tasks_done():
		show_hint("Not tired yet. (Finish today's tasks first.)")
		return
	journal.open_end_page()


func on_day_ended():
	if busy:
		return
	busy = true
	var today = Story.get_day(GameState.loop, GameState.day)
	await fade.fade_out(1.0)
	await montage.play(today["night"])
	GameState.start_next_day()
	top_bar.set_day(GameState.day)
	load_room(bedroom_path)
	await montage.play(Story.get_day(GameState.loop, GameState.day)["wake"])
	await fade.fade_in(1.0)
	busy = false
# radio done -> the same room, but at night
func on_radio_finished():
	busy = true
	journal.close()
	await fade.fade_out(1.0)
	GameState.is_night = true
	load_room(GameState.current_room)
	await fade.fade_in(1.0)
	busy = false
	show_hint("It's late. Time to go to bed.")

# she walks to the dock, dies, and a new loop starts
func on_dock_chosen():
	if busy:
		return
	busy = true
	var today = Story.get_day(GameState.loop, GameState.day)
	await fade.fade_out(0.8)
	await montage.play(Story.WALK_TO_DOCK)
	await montage.play(today["death"])
	GameState.start_next_loop()
	top_bar.set_day(GameState.day)
	load_room(bedroom_path)
	await montage.play(Story.get_day(GameState.loop, GameState.day)["wake"])
	await fade.fade_in(1.0)
	busy = false


# TEST KEY: F10 = next day instantly. Delete later.
func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_F10 and not busy:
		GameState.start_next_day()
		top_bar.set_day(GameState.day)
		load_room(bedroom_path)
