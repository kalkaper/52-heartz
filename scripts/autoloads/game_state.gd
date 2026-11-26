extends Node

# --- where we are in the story ---
var loop = 1
var day = 1


# --- what the player has done ---
var has_journal = false
var done_tasks = []     # ids of tasks finished today, like ["t1", "t2"]
var notes = {}          # choices made in radio talks, like {"listened": true}
var day_flags = {}      # things that happened TODAY only. cleared every new day
var is_night = false    # true after the radio task is done, until she sleeps

# --- where the player is right now ---
var current_room = ""

# --- saved radio talks. The key is "loop_day", like "1_1" ---
var radio_logs = {}
var freq52_logs = {}    # day number -> lines. never cleared, so it survives death

func log_key(loop_number, day_number):
	return str(loop_number) + "_" + str(day_number)


func save_radio_lines(lines):
	# duplicate() makes a copy. Without it, the radio would wipe our saved lines
	# the next time it clears its own list
	radio_logs[log_key(loop, day)] = lines.duplicate()


func get_radio_lines(loop_number, day_number):
	var key = log_key(loop_number, day_number)
	if radio_logs.has(key):
		return radio_logs[key]
	return []


func is_task_done(task_id):
	return done_tasks.has(task_id)


func mark_task_done(task_id):
	if not done_tasks.has(task_id):
		done_tasks.append(task_id)


# a new day starts with fresh tasks
func start_next_day():
	day += 1
	done_tasks.clear()
	day_flags.clear()
	is_night = Story.get_day(loop, day)["storm"]
	
# she died: new loop, day 1. notes stay. the log page only reads the current loop, so old logs vanish
func start_next_loop():
	loop += 1
	day = 1
	done_tasks.clear()
	day_flags.clear()
	is_night = Story.get_day(loop, day)["storm"]	
	
func save_freq52_lines(day_number, lines):
	freq52_logs[day_number] = lines.duplicate()


func get_freq52_lines(day_number):
	if freq52_logs.has(day_number):
		return freq52_logs[day_number]
	return []
# a fresh game. The main menu's Play button and the end of the credits call this
func reset():
	loop = 1
	day = 1
	done_tasks.clear()
	notes.clear()
	day_flags.clear()
	radio_logs.clear()
	freq52_logs.clear()
	has_journal = false
	is_night = false
	current_room = ""
