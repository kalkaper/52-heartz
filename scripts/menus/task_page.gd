extends Control

signal task_requested(task_id)

@onready var rows = $RowsOfTask


func _ready():
	refresh()


func refresh():
	for child in rows.get_children():
		rows.remove_child(child)
		child.queue_free()
	var data = Story.get_day(GameState.loop, GameState.day)
	var others_done = are_others_done()
	var dim = "[color=#00000066]"
	var text = ""
	for task_id in data["tasks"]:
		# "[" would be read as a tag, so we write it as "[lb]"
		var title = task_title(task_id, data).replace("[", "[lb]")
		if GameState.is_task_done(task_id):
			text += "[color=#000000][s]" + title + "[/s][/color]\n"
		elif data["blocked"].has(task_id):
			text += dim + title + "[/color]\n"
		elif task_id == "radio" and not others_done:
			text += dim + title + "[/color]\n"
		elif GameState.current_room != task_room(task_id):
			text += dim + title + "[/color]\n"
		else:
			text += "[color=#000000][url=" + task_id + "]" + title + "[/url][/color]\n"

	# one small hint line while something can't be done yet
	if not are_all_done():
		if some_task_elsewhere(data):
			text += "\n[color=#00000088]Some tasks need another room.[/color]"
		elif data["blocked"].size() > 0:
			text += "\n[color=#00000088]The storm is too strong to go out.[/color]"
		elif not others_done:
			text += "\n[color=#00000088]Finish the other tasks first.[/color]"

	var label = RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.scroll_active = false
	label.custom_minimum_size = Vector2(560, 0)
	label.add_theme_constant_override("line_separation", 12)
	label.text = text
	label.meta_clicked.connect(on_task_clicked)
	rows.add_child(label)


func task_title(task_id, data):
	if task_id == "radio":
		return data["radio_title"]
	return Story.TASKS[task_id]["title"]


# the room a task must be done in. The radio is always the radio room.
# To change a task's room, edit "room" in Story.TASKS
func task_room(task_id):
	if task_id == "radio":
		return Story.RADIO_ROOM
	return Story.TASKS[task_id].get("room", Story.RADIO_ROOM)


# true if an unfinished, not-blocked task needs a different room than the one we're in
func some_task_elsewhere(data):
	for task_id in data["tasks"]:
		if GameState.is_task_done(task_id) or data["blocked"].has(task_id):
			continue
		if GameState.current_room != task_room(task_id):
			return true
	return false


# every required task except the radio is done (blocked tasks don't count)
func are_others_done():
	for task_id in Story.required_tasks(GameState.loop, GameState.day):
		if task_id != "radio" and not GameState.is_task_done(task_id):
			return false
	return true


func are_all_done():
	for task_id in Story.required_tasks(GameState.loop, GameState.day):
		if not GameState.is_task_done(task_id):
			return false
	return true


func on_task_clicked(meta):
	task_requested.emit(str(meta))


func mark_done(task_id):
	GameState.mark_task_done(task_id)
	refresh()
