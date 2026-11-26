extends RoomBase
# storm (a day with blocked tasks, like day 4): the dark lamp room
func apply_night():
	var background = get_node_or_null("Background")
	if not (background is TextureRect) or background.texture == null:
		return
	var storm = Story.lamp_off(GameState.loop, GameState.day)
	if not storm:
		return
	var path = background.texture.resource_path.get_base_dir() + "/lamp_room_dark.png"
	if ResourceLoader.exists(path):
		background.texture = load(path)
		
func handle_action(action):
	match action:
		"go_below":
			room_change_requested.emit("res://scenes/world/bedroom_back.tscn")
		_:
			print("Unknown action: ", action)
