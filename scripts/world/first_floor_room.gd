extends RoomBase

func handle_action(action):
	match action:
		"go_outside":
			room_change_requested.emit("res://scenes/world/outside.tscn")
		"go_above":
			room_change_requested.emit("res://scenes/world/bedroom_back.tscn")
		_:
			print("Unknown action: ", action)
