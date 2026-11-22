extends Control

signal task_requested(task_id)

var tasks = [
	{"id": "t1", "title": "Make the bed", "done": false},
	{"id": "t2", "title": "Charge the radio", "done": false},
	{"id": "radio", "title": "Daily radio call", "done": false}
]

@onready var rows = $RowsOfTask


func _ready():
	refresh()


func refresh():
	for child in rows.get_children():
		rows.remove_child(child)
		child.queue_free()
		
	var others_done = are_others_done()
	var empty_style = StyleBoxEmpty.new()
	var ink_color = "#2b2118"
	var done_color = "#6e6259"
	var locked_color = "#8c8075"
	
	for task in tasks:
		var button = Button.new()
		button.custom_minimum_size = Vector2(0, 60)
		button.flat = true
		
		# Remove all button background boxes and focus outlines
		button.add_theme_stylebox_override("normal", empty_style)
		button.add_theme_stylebox_override("hover", empty_style)
		button.add_theme_stylebox_override("pressed", empty_style)
		button.add_theme_stylebox_override("disabled", empty_style)
		button.add_theme_stylebox_override("focus", empty_style)
		
		# Create the journal text label
		var label = RichTextLabel.new()
		label.bbcode_enabled = true
		label.fit_content = true
		label.scroll_active = false
		label.autowrap_mode = TextServer.AUTOWRAP_OFF
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT)
		label.add_theme_font_size_override("normal_font_size", 32)

		
		if task["done"]:
			label.text = "[color=" + done_color + "][s]- " + task["title"] + "[/s][/color]"
			button.disabled = true
		elif task["id"] == "radio" and not others_done:
			label.text = "[color=" + locked_color + "]- " + task["title"] + " (locked)[/color]"
			button.disabled = true
		else:
			label.text = "[color=" + ink_color + "]- " + task["title"] + "[/color]"
			button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			button.pressed.connect(on_row_pressed.bind(task["id"]))
			
		button.add_child(label)
		rows.add_child(button)


func are_others_done():
	for task in tasks:
		if task["id"] != "radio" and not task["done"]:
			return false
	return true


func on_row_pressed(task_id):
	task_requested.emit(task_id)
	if task_id == "radio":
		return  # the journal starts the radio, and marks it done when it ends
	# temporary: other tasks count as done when clicked, until the real popups exist
	mark_done(task_id)


func are_all_done():
	for task in tasks:
		if not task["done"]:
			return false
	return true


func mark_done(task_id):
	for task in tasks:
		if task["id"] == task_id:
			task["done"] = true
	refresh()
