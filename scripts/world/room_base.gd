class_name RoomBase
extends Control

# rooms shout this when the player wants to go somewhere else
signal room_change_requested(scene_path)
signal task_requested(task_id)    # main.gd opens the task
signal montage_requested(steps)   # main.gd plays it (3 second inspect texts, etc.)

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
	if GameState.is_night:
		apply_night()

func on_spot_hovered(spot):
	hide_timer.stop()
	mouse_on_menu = false
	if current_spot != null and current_spot != spot:
		current_spot.hide_outline()
	current_spot = spot
	spot.show_outline()
	build_menu(spot)
	if menu.get_child_count() == 0:
		menu.hide()
		return
	menu.global_position = spot.get_menu_position()
	menu.show()
	# wait one frame so the menu knows its size, then keep it on the screen
	await get_tree().process_frame
	keep_menu_on_screen()


func on_spot_unhovered(spot):
	# wait a moment, in case the mouse is just moving onto the text
	hide_timer.start()


func close_menu():
	mouse_on_menu = false
	menu.hide()
	if current_spot != null:
		current_spot.hide_outline()
	current_spot = null


func keep_menu_on_screen():
	var screen = get_viewport_rect().size
	var pos = menu.global_position
	pos.x = clamp(pos.x, 20, screen.x - menu.size.x - 20)
	pos.y = clamp(pos.y, 20, screen.y - menu.size.y - 20)
	menu.global_position = pos


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


func build_menu(spot):
	clear_menu()
	for i in range(spot.choice_texts.size()):
		var action = ""
		if i < spot.choice_actions.size():
			action = spot.choice_actions[i]
		add_choice(spot.choice_texts[i], action)
	# tasks that can be done at this object today
	for task_id in Story.tasks_at(GameState.loop, GameState.day, scene_file_path, spot.name):
		add_choice(Story.task_def(task_id)["choice"], "task:" + task_id)


func add_choice(text, action):
	var button = Button.new()
	button.text = text
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


func on_choice_chosen(action):
	mouse_on_menu = false
	close_menu()
	if action.begins_with("task:"):
		task_requested.emit(action.trim_prefix("task:"))
		return
	var steps = Story.inspect_steps(action)
	if steps.size() > 0:
		montage_requested.emit(steps)
		return
	handle_action(action)


func clear_menu():
	for child in menu.get_children():
		menu.remove_child(child)
		child.queue_free()


# every room fills this in with its own choices
func handle_action(action):
	print("No handler for action: ", action)
	
# swaps the Background to its night picture, if that file exists
func apply_night():
	var background = get_node_or_null("Background")
	if background is TextureRect and background.texture != null:
		var night = night_version(background.texture)
		if night != null:
			background.texture = night


# swaps one spot's picture to its night version, if that file exists
func swap_to_night(spot):
	if spot.texture_normal != null:
		var night = night_version(spot.texture_normal)
		if night != null:
			spot.texture_normal = night


# bedroom_day.png -> bedroom_night.png, or X.png -> X_night.png. null if no such file
func night_version(texture):
	var path = texture.resource_path
	if path == "":
		return null
	var base = path.get_basename()
	var extension = path.get_extension()
	var candidates = []
	if base.ends_with("_day"):
		candidates.append(base.trim_suffix("_day") + "_night." + extension)
	candidates.append(base + "_night." + extension)
	for candidate in candidates:
		if ResourceLoader.exists(candidate):
			return load(candidate)
	return null
