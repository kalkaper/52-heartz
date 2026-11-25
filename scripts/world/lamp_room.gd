extends RoomBase

func handle_action(action):
	match action:
		"go_below":
			room_change_requested.emit("res://scenes/world/bedroom_back.tscn")
		_:
			print("Unknown action: ", action)
