extends RoomBase

signal journal_picked_up
signal sleep_requested
# at night only these spots can be clicked
# at night only these spots show and work
var night_spots = ["BedSpot", "WindowSpot", "FloorSpot", "DoorSpot"]


func _ready():
	super._ready()
	if GameState.is_night:
		for spot in spots.get_children():
			if night_spots.has(spot.name):
				swap_to_night(spot)
			else:
				spot.hide()
# called by main.gd when we come back and the journal is already taken
func hide_journal_spot():
	$ObjectSpots/JournalSpot.hide()
	# daytime picture without the journal on the table (night already has none)
	if not GameState.is_night:
		var path = "res://assets/textures/Bedroom/bedroom_day_nojournal.png"
		if ResourceLoader.exists(path):
			$Background.texture = load(path)

func handle_action(action):
	match action:
		"go_radio_room":
			room_change_requested.emit("res://scenes/world/radio_room.tscn")
		"pick_up_journal":
			print("Journal picked up")
			hide_journal_spot()
			journal_picked_up.emit()
		"inspect_bed":
			print("Inspect the bed (nothing yet)")
		"go_to_sleep":
			sleep_requested.emit()
		"inspect_window":
			print("Look outside (later: the window view)")
		"inspect_lamp":
			print("Inspect the lamp (nothing yet)")
		"look_photos":
			print("Look at the photos (nothing yet)")
		"look_things":
			print("Look through the things (nothing yet)")
		"open_locker_1":
			print("Locker 1 opens (nothing inside yet)")
		"open_locker_2":
			print("Locker 2 opens (nothing inside yet)")
		"look_behind":
			room_change_requested.emit("res://scenes/world/bedroom_back.tscn")
		_:
			print("Unknown action: ", action)
