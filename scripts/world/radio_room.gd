extends RoomBase

func handle_action(action):
	match action:
		"go_bedroom":
			room_change_requested.emit("res://scenes/world/bedroom.tscn")
		"inspect_window":
			print("Look outside (later: the window view)")
		_:
			print("Unknown action: ", action)
