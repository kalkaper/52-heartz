extends Control
signal journal_picked_up

# --- how the choice text looks ---
@export var choice_font: Font
var choice_font_size = 40
var normal_color = Color("ffffff")
var hover_color = Color("ffd98a")
var outline_color = Color("000000")

# --- what we are hovering right now ---
var current_spot = null
var mouse_on_menu = false

@onready var spots = $ObjectSpots
@onready var menu = $ChoicesWhenObjectHovered
@onready var hide_timer = $Timer


func _ready():
	menu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu.hide()
	hide_timer.wait_time = 0.2
	hide_timer.one_shot = true
	hide_timer.timeout.connect(on_hide_timer_timeout)
	for spot in spots.get_children():
		spot.hovered.connect(on_spot_hovered)
		spot.unhovered.connect(on_spot_unhovered)


# --- hovering ---

func on_spot_hovered(spot):
	hide_timer.stop()
	if current_spot != null and current_spot != spot:
		current_spot.hide_outline()
	current_spot = spot
	spot.show_outline()
	if spot.choice_texts.size() == 0:
		menu.hide()
		return
	build_menu(spot)
	menu.global_position = spot.get_menu_position()
	menu.show()


func on_spot_unhovered(spot):
	# wait a moment, in case the mouse is just moving onto the text
	hide_timer.start()


func on_menu_mouse_entered():
	mouse_on_menu = true
	hide_timer.stop()


func on_menu_mouse_exited():
	mouse_on_menu = false
	hide_timer.start()


func on_hide_timer_timeout():
	if mouse_on_menu:
		return
	close_menu()


func close_menu():
	menu.hide()
	if current_spot != null:
		current_spot.hide_outline()
	current_spot = null


# --- the choice text ---

func build_menu(spot):
	clear_menu()
	for i in range(spot.choice_texts.size()):
		var action = ""
		if i < spot.choice_actions.size():
			action = spot.choice_actions[i]
		var button = Button.new()
		button.text = spot.choice_texts[i]
		button.flat = true
		button.focus_mode = Control.FOCUS_NONE
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		if choice_font != null:
			button.add_theme_font_override("font", choice_font)
		button.add_theme_font_size_override("font_size", choice_font_size)
		button.add_theme_color_override("font_color", normal_color)
		button.add_theme_color_override("font_hover_color", hover_color)
		button.add_theme_color_override("font_pressed_color", hover_color)
		button.add_theme_color_override("font_outline_color", outline_color)
		button.add_theme_constant_override("outline_size", 8)
		button.mouse_entered.connect(on_menu_mouse_entered)
		button.mouse_exited.connect(on_menu_mouse_exited)
		button.pressed.connect(on_choice_chosen.bind(action))
		menu.add_child(button)


func clear_menu():
	for child in menu.get_children():
		menu.remove_child(child)
		child.queue_free()


# --- what each choice does (everything only prints for now) ---

func on_choice_chosen(action):
	mouse_on_menu = false
	close_menu()
	match action:
		"inspect_bed":
			print("Inspect the bed (nothing yet)")
		"go_to_sleep":
			print("Go to sleep (later: opens the End the day page)")
		"inspect_window":
			print("Look outside (later: the window view)")
		"go_radio_room":
			print("Go to the radio room (does nothing yet)")
		"pick_up_journal":
			print("Journal picked up")
			$ObjectSpots/JournalSpot.hide()
			journal_picked_up.emit()
		"inspect_lamp":
			print("Inspect the lamp (nothing yet)")
		"look_photos":
			print("Look at the photos (nothing yet)")
		"look_things":
			print("Look through the things (nothing yet)")
		"open_locker_1":
			print("Locker 1 opens (nothing inside yet)")
		"open_locker_2":
			print("Locker 2 opens (nothing inside yet)")
		"look_behind":
			print("Look behind (does nothing yet)")
		_:
			print("Unknown action: ", action)
