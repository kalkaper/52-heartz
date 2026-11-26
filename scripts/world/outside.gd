extends RoomBase
# the night picture has its own name, in the same folder as the day picture
func apply_night():
	var background = get_node_or_null("Background")
	if not (background is TextureRect) or background.texture == null:
		return
	var path = background.texture.resource_path.get_base_dir() + "/nighttime_map.png"
	if ResourceLoader.exists(path):
		background.texture = load(path)

func handle_action(action):
	match action:
		"go_lighthouse":
			room_change_requested.emit("res://scenes/world/first_floor_room.tscn")
		"go_dock":
			print("uh uh")
			#room_change_requested.emit("res://scenes/world/dock.tscn")
		_:
			print("Unknown action: ", action)
