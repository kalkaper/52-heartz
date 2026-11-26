extends Control

signal task_requested(task_id)   # unused now, kept so the journal's connection still works

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
		var title = task_title(task_id, data).replace("[", "[lb]")
		if GameState.is_task_done(task_id):
			text += "[color=#000000][s]" + title + "[/s][/color]\n"
		elif data["blocked"].has(task_id):
			text += dim + title + "[/color]\n"
		elif task_id == "radio" and not others_done:
			text += dim + title + "[/color]\n"
		else:
			text += "[color=#000000]" + title + "[/color]\n"
	if not are_all_done():
		if data["blocked"].size() > 0:
			text += "\n[color=#00000088]The storm is too strong to go out.[/color]"
		else:
			text += "\n[color=#00000088]Do them around the lighthouse.[/color]"

	var label = RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.scroll_active = false
	label.custom_minimum_size = Vector2(560, 0)
	label.add_theme_constant_override("line_separation", 12)
	label.text = text
	rows.add_child(label)


func task_title(task_id, data):
	if task_id == "radio":
		return data["radio_title"]
	return Story.TASKS[task_id]["title"]


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


func mark_done(task_id):
	GameState.mark_task_done(task_id)
	refresh()
