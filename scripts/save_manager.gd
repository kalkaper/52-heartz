extends Node

const SAVE_PATH := "user://scripts/save_file.json"

func save_game(data: Dictionary) -> Error:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_line(JSON.stringify(data))
	file.close()
	return OK

func load_game(default_data: Dictionary = {}) -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return default_data.duplicate(true)
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return default_data.duplicate(true)
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return default_data.duplicate(true)
	return parsed
