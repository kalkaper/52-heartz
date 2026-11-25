extends Control

# the radio tells the journal "I'm done" with this signal
signal finished

# --- things the radio remembers ---
var loop = 1
var day = 1
var lines = []            # every line from the json file
var line_index = 0        # a bookmark: which line we are on
var log_lines = []        # every line shown, for the Log page later
var day_choices = {}      # choices made in THIS call only, used for "if" lines
var is_typing = false
var typing_tween = null
var can_use_52hz = false  # the story will unlock this later

# --- ink colors ---
var captain_color = Color("2b2118")
var you_color = Color("785892ff")
var whale_color = Color("1f4e79")
var system_color = Color("6b6b6b")

# --- the nodes inside this scene ---
@onready var text_label = $Text
@onready var choices_container = $ChoicesContainer
@onready var continue_button = $ContinueButton
@onready var button_52hz = $"52HzButton"


func _ready():
	continue_button.pressed.connect(on_continue_pressed)
	button_52hz.pressed.connect(on_52hz_pressed)
	button_52hz.visible = can_use_52hz
	# the text box scrolls with the mouse wheel, and follows the newest line
	text_label.scroll_active = true
	text_label.scroll_following = true


# the journal calls this to start a conversation
func start(loop_number, day_number):
	loop = loop_number
	day = day_number
	line_index = 0
	log_lines.clear()
	day_choices.clear()
	clear_choices()
	text_label.clear()
	text_label.visible_characters = -1
	button_52hz.visible = can_use_52hz
	load_file()
	show()
	show_next_line()


# builds the file name from loop and day, like l1_d1.json, and reads it
func load_file():
	var folder = "res://assets/dialogues/"
	var path = folder + "l" + str(loop) + "_d" + str(day) + ".json"
	# no file for this day yet: use the placeholder, so the game still runs
	if not FileAccess.file_exists(path):
		print("No radio file ", path, ", using the placeholder")
		path = folder + "placeholder_radio_log1.json"
	if not FileAccess.file_exists(path):
		print("Radio file not found: ", path)
		lines = [{"who": "you", "text": "(missing file: " + path + ")"}]
		return
	var file_text = FileAccess.get_file_as_string(path)
	var data = JSON.parse_string(file_text)
	if data == null:
		print("Radio file has a typo (not valid JSON): ", path)
		lines = [{"who": "you", "text": "(broken file: " + path + ")"}]
		return
	lines = data["lines"]


# --- showing lines ---

# moves the bookmark forward and shows the next line
func show_next_line():
	# skip lines that need a note we don't have
	while line_index < lines.size() and not line_is_allowed(lines[line_index]):
		line_index += 1
	if line_index >= lines.size():
		finish()
		return
	var line = lines[line_index]
	line_index += 1
	if line.has("choice"):
		show_choice(line["choice"])
	else:
		show_normal_line(line)


func line_is_allowed(line):
	if not line.has("if"):
		return true
	return day_choices.has(line["if"])

# writes one line under the previous ones
func show_normal_line(line):
	var who = line["who"]
	var words = line["text"]
	var ink = you_color
	if who == "whale":
		words = words.to_lower()
		ink = whale_color
	elif who == "captain":
		ink = captain_color
	elif who == "system":
		ink = system_color

	# remember how much text was already there, so only the new line gets typed
	var old_total = text_label.get_total_character_count()

	# "[" would be read as a color tag, so we write it as "[lb]"
	var safe_words = words.replace("[", "[lb]")
	text_label.append_text("[color=#" + ink.to_html(false) + "]" + safe_words + "[/color]\n\n")

	log_lines.append({"who": who, "text": words})
	start_typing(old_total)


# makes only the NEW part of the text appear letter by letter
func start_typing(from_count):
	var to_count = text_label.get_total_character_count()
	text_label.visible_characters = from_count
	is_typing = true
	continue_button.show()
	var seconds = (to_count - from_count) * 0.03
	if typing_tween != null:
		typing_tween.kill()
	typing_tween = create_tween()
	typing_tween.tween_property(text_label, "visible_characters", to_count, seconds)
	typing_tween.finished.connect(on_typing_finished)


func on_typing_finished():
	is_typing = false
	text_label.visible_characters = -1


func on_continue_pressed():
	if is_typing:
		# still writing: finish the line right now
		typing_tween.kill()
		text_label.visible_characters = -1
		is_typing = false
	else:
		show_next_line()


# --- choices ---

func show_choice(options):
	continue_button.hide()
	clear_choices()
	for option in options:
		var button = Button.new()
		button.text = option["text"]
		button.custom_minimum_size = Vector2(0, 60)
		
		# 1. Remove the dark background and focus box
		button.flat = true
		button.focus_mode = Control.FOCUS_NONE
		
		# 2. Match the 'you' ink color across all states
		button.add_theme_color_override("font_color", you_color)
		button.add_theme_color_override("font_hover_color", you_color)
		button.add_theme_color_override("font_pressed_color", you_color.darkened(0.2))
		
		# 3. Set outline color and toggle outline thickness on hover
		button.add_theme_color_override("font_outline_color", Color.WHITE) # Change outline color as needed
		button.add_theme_constant_override("outline_size", 0)
		button.mouse_entered.connect(func(): button.add_theme_constant_override("outline_size", 4))
		button.mouse_exited.connect(func(): button.add_theme_constant_override("outline_size", 0))
		
		button.pressed.connect(on_choice_pressed.bind(option))
		choices_container.add_child(button)


func on_choice_pressed(option):
	if option.has("set"):
		GameState.notes[option["set"]] = true
		day_choices[option["set"]] = true
	clear_choices()
	continue_button.show()
	# her answer is written on the page like any other line
	show_normal_line({"who": "you", "text": option["text"]})


func clear_choices():
	for child in choices_container.get_children():
		choices_container.remove_child(child)
		child.queue_free()


# --- ending ---

func finish():
	GameState.save_radio_lines(log_lines)
	print("Radio finished. Lines saved: ", log_lines.size())
	hide()
	finished.emit()


func on_52hz_pressed():
	print("52 Hz pressed (does nothing yet)")


# TEST KEY: F9 shows or hides the 52 Hz button. Delete later.
func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_F9:
		can_use_52hz = not can_use_52hz
		button_52hz.visible = can_use_52hz
