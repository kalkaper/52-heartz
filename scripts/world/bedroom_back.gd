extends RoomBase

# at night: lit staircase, or dark during the storm (same folder as the day picture)
func apply_night():
	var background = get_node_or_null("Background")
	if not (background is TextureRect) or background.texture == null:
		return
	var storm = Story.lamp_off(GameState.loop, GameState.day)
	var file = "Staircase_night_lit.png"
	if storm:
		file = "Staircase_night_dark.png"
	var path = background.texture.resource_path.get_base_dir() + "/" + file
	if ResourceLoader.exists(path):
		background.texture = load(path)


func handle_action(action):
	match action:
		"look_behind":
			room_change_requested.emit("res://scenes/world/bedroom.tscn")
		"go_above":
			if GameState.is_night:
				room_change_requested.emit("res://scenes/world/lamp_room.tscn")
			else:
				montage_requested.emit([{"text": "The wind is too strong.", "seconds": 2.0}])
		"go_below":
			if GameState.is_night:
				montage_requested.emit([{"text": "The floor is too slippery.", "seconds": 2.0}])
			else:
				room_change_requested.emit("res://scenes/world/first_floor_room.tscn")
		_:
			print("Unknown action: ", action)
