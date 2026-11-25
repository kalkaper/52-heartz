extends RoomBase

func handle_action(action):
	match action:
		"go_lighthouse":
			room_change_requested.emit("res://scenes/world/first_floor_room.tscn")
		"go_dock":
			print("uh uh")
			#room_change_requested.emit("res://scenes/world/dock.tscn")
		_:
			print("Unknown action: ", action)
