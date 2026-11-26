extends Control

# --- ink colors: same as the radio, so the log looks like what she heard ---
var captain_color = Color("2b2118")
var you_color = Color("785892ff")
var whale_color = Color("1f4e79")
var button_ink = Color("2b2118")
var system_color = Color("6b6b6b")

# --- the nodes inside this scene (names must match exactly) ---
@onready var day_list = $DayList
@onready var log_text = $LogText


func _ready():
	log_text.bbcode_enabled = true
	# every time the Log page becomes visible, rebuild the list
	visibility_changed.connect(on_visibility_changed)


func on_visibility_changed():
	if is_visible_in_tree():
		refresh()


# rebuilds the "Log day n" list from the radio logs saved in GameState
func refresh():
	for child in day_list.get_children():
		day_list.remove_child(child)
		child.queue_free()
	log_text.clear()

	var found_any = false
	# days 1 .. today. A day only gets a button if its radio was finished
	for day_number in range(1, GameState.day + 1):
		if GameState.get_radio_lines(GameState.loop, day_number).size() == 0 and GameState.get_freq52_lines(day_number).size() == 0:
			continue
		found_any = true
		day_list.add_child(make_day_button(day_number))

	if found_any:
		log_text.append_text("Pick a day on the left.")
	else:
		log_text.append_text("No radio logs yet.")


# a button that looks like plain text, and gets a soft highlight on hover
# a button that looks like plain text, and gets a text outline on hover
func make_day_button(day_number):
	var button = Button.new()
	button.text = "Log day " + str(day_number)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.custom_minimum_size = Vector2(0, 50)
	button.focus_mode = Control.FOCUS_NONE

	# black ink in every state
	button.add_theme_color_override("font_color", button_ink)
	button.add_theme_color_override("font_hover_color", button_ink)
	button.add_theme_color_override("font_pressed_color", button_ink)
	button.add_theme_color_override("font_hover_pressed_color", button_ink)

	# no box in any state (keeps the 8px margin)
	var plain = StyleBoxEmpty.new()
	plain.set_content_margin_all(8)
	button.add_theme_stylebox_override("normal", plain)
	button.add_theme_stylebox_override("hover", plain)
	button.add_theme_stylebox_override("pressed", plain)
	button.add_theme_stylebox_override("hover_pressed", plain)

	# text outline on hover
	button.add_theme_color_override("font_outline_color", Color.WHITE)
	button.add_theme_constant_override("outline_size", 0)
	button.mouse_entered.connect(func(): button.add_theme_constant_override("outline_size", 4))
	button.mouse_exited.connect(func(): button.add_theme_constant_override("outline_size", 0))

	button.pressed.connect(show_day.bind(day_number))
	return button



# writes the saved radio lines of that day on the right page
func show_day(day_number):
	var lines = GameState.get_freq52_lines(day_number) + GameState.get_radio_lines(GameState.loop, day_number)
	log_text.clear()
	log_text.append_text("Day " + str(day_number) + "\n\n")
	for line in lines:
		var ink = you_color
		if line["who"] == "whale":
			ink = whale_color
		elif line["who"] == "captain":
			ink = captain_color
		elif line["who"] == "system":
			ink = system_color
		# "[" would be read as a color tag, so we write it as "[lb]"
		var safe_words = line["text"].replace("[", "[lb]")
		log_text.append_text("[color=#" + ink.to_html(false) + "]" + safe_words + "[/color]\n\n")
