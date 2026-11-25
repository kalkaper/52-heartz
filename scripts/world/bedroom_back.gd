extends RoomBase

func handle_action(action):
	match action:
		"look_behind":
			room_change_requested.emit("res://scenes/world/bedroom.tscn")
		"go_above":
			room_change_requested.emit("res://scenes/world/lamp_room.tscn")
		"go_below":
			room_change_requested.emit("res://scenes/world/first_floor_room.tscn")
		_:
			print("Unknown action: ", action)
