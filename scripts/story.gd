class_name Story
extends RefCounted

const RADIO_ROOM = "res://scenes/world/radio_room.tscn"

const BEDROOM = "res://scenes/world/bedroom.tscn"
const BEDROOM_BACK = "res://scenes/world/bedroom_back.tscn"
const FIRST_FLOOR = "res://scenes/world/first_floor_room.tscn"
const OUTSIDE = "res://scenes/world/outside.tscn"
const DOCK = "res://scenes/world/dock.tscn"   # doesn't exist yet -> shows placeholder text
const LAMP_ROOM = "res://scenes/world/lamp_room.tscn"
const TASK_DONE_TEXT = "You finished the task"
const TASK_DONE_SECONDS = 2.0

# the 6 unique tasks. "scene" = the popup scene the other programmer makes ("" = click finishes it)
const TASKS = {
	"make_bed": {"title": "Make the bed", "scene": "res://scenes/tasks/make_bed.tscn",
		"room": BEDROOM, "spots": ["BedSpot"], "choice": "Make the bed?"},
	"charge_radio": {"title": "Charge the radio", "scene": "res://scenes/tasks/charge_radio.tscn",
		"room": RADIO_ROOM, "spots": ["RadioSpot"], "choice": "Charge the radio?"},
	"change_lamp": {"title": "Change the lamp", "scene": "res://scenes/tasks/change_lamp.tscn",
		"room": BEDROOM, "spots": ["LanternSpot"], "choice": "Change the lamp?"},
	"extra_task_1": {"title": "Clear the dust", "scene": "res://scenes/tasks/extra_task_1.tscn",
		"room": BEDROOM, "spots": ["WhiteboardSpot", "BookpileSpot"], "choice": "Clean off the dust?"},
	"extra_task_2": {"title": "Tune the frequency", "scene": "res://scenes/tasks/extra_task_2.tscn",
		"room": RADIO_ROOM, "spots": ["RadioSpot"], "choice": "Tune the frequency?"},
}

# the daily radio call is not in TASKS (it is never picked at random), but it also lives on an object
const RADIO_CALL = {"room": RADIO_ROOM, "spots": ["RadioSpot"], "choice": "Make the daily radio call?"}

# "Inspect" choices: action name -> text of the 3 second black montage. Rewrite the text freely
const INSPECT = {
	"inspect_bed": "3 months here, and you only washed the blanket 2 times",
	"inspect_window": "Nothing out there but fog and the sea.",
	"inspect_lamp": "Its just normal lantern bruh",
	"look_photos": "You added another tally, counting that you wanna go back home",
	"look_things": "Old books, some from your dead boyfriend",
	"open_locker_1": "Locked.",
	"open_locker_2": "Empty, except for some cobweb",
	"inspect_radio": "It hums. sounds like, bzzzt, you're bored of it",
}
# inspect actions that show a picture instead of black text (day or night one)
const INSPECT_IMAGES = {
	"inspect_window": {
		"day": "res://assets/textures/Bedroom/outside_view_sea_day.png",
		"night": "res://assets/textures/Bedroom/outside_view_sea_night.png",
	},
}
# montage step keys: "text" (always shown), "placeholder" (shown only if no picture),
# "scene" (uses that room's Background), "image" (res:// path), "sound", "seconds" (default 1.5)

const WALK_TO_DOCK = [
	{"scene": BEDROOM, "night": true, "placeholder": "(bedroom)", "seconds": 1.3},
	{"scene": BEDROOM_BACK, "night": true, "placeholder": "(bedroom, looking behind - placeholder)", "seconds": 1.3},
	{"scene": FIRST_FLOOR, "night": true, "placeholder": "(first floor - placeholder)", "seconds": 1.3},
	{"scene": OUTSIDE, "night": true, "placeholder": "(outside)", "seconds": 1.3},
	{"image" :"res://assets/textures/Visions/dock_night.png","effect": "wind", "params": {"strength": 0.001}, "seconds": 2.5,},
]

const DEATH_L1_D2 = [
	{"image" :"res://assets/textures/Visions/stormy_spooky_nightmare_idk.png","effect": "wind", "params": {"strength": 0.001}, "seconds": 2.5,},
	{"same_image": true, "text": "the wind blew too fast", "params": {"strength": 0.002}, "seconds": 2.5},
	{"same_image": true, "text": "You tried to find that wonderful eye you saw on your vision", "params": {"strength": 0.002}, "seconds": 2.5},
	{"image" :"res://assets/textures/Visions/whale_eye.png","effect": "underwater_whale_eye", "seconds": 0.25,},
	{"image" :"res://assets/textures/Visions/stormy_spooky_nightmare_idk.png","effect": "wind", "params": {"strength": 0.001}, "seconds": 0.01,},
	{"same_image": true, "text": "You were surprised, you slipped", "params": {"strength": 0.003}, "seconds": 2.5},
	{"text": "You fell down, and drowned...", "seconds": 2.0},
]

const DEATH_L1_D4 = [
	{"image" :"res://assets/textures/Visions/stormy_spooky_nightmare_idk.png","effect": "wind", "params": {"strength": 0.001}, "seconds": 2.5,},
	{"same_image": true, "text": "the wind blew too fast", "params": {"strength": 0.003}, "seconds": 2.5},
	{"same_image": true, "text": "you heard the whale sung like an angel", "params": {"strength": 0.0045}, "seconds": 2.5},
	{"same_image": true, "text": "you can't help but try to listen closer", "params": {"strength": 0.0045}, "seconds": 2.5},
	{"text": "(img 2: her silhouette on the edge of the dock, 8-10 whales leap around her)\n*whale screech*", "seconds": 2.5},
	{"text": "You slipped, and drowned...", "seconds": 2.0},
]

const HEADACHE_L1_D2 = [
	{"text": "you felt a strange headache...", "seconds": 2.5},
	{"text": "You collapsed on floor", "seconds": 1.8},
	{"image" :"res://assets/textures/Visions/whale_eye.png", "seconds": 2.5, "effect" : "underwater_whale_eye"},
	{"same_image": true, "text": "You See A Vision...", "seconds": 3.5},
	{"same_image": true, "text": "The Whale Eyes.", "seconds": 4.5},
	{"same_image": true, "text": "Keep Staring At YOU", "seconds": 4.5},
	{"same_image": true, "text": "Why?", "seconds": 3.0},
	{"text": "you woke up.", "seconds": 2.0},
	{"text": "\"mrs [name]! mrs [name]?!\"\n(the radio is buzzing)", "seconds": 2.5},
]

const VISION_1 = [
	{
		"image": "res://assets/textures/Visions/whale_eye.png",
		"effect": "underwater_whale_eye",
		"placeholder": "(VISION 1: whale eye - png missing)",
		"seconds": 10.0,
	},
]
# "night": true = the room's night picture. "params" = shader settings (wind strength)
const LAMP_YES = [
	{"scene": RADIO_ROOM, "night": true, "placeholder": "(radio room)", "seconds": 1.3},
	{"scene": BEDROOM, "night": true, "placeholder": "(bedroom)", "seconds": 1.3},
	{"scene": BEDROOM_BACK, "night": true, "placeholder": "(staircase, dark)", "seconds": 1.3},
	{"scene": LAMP_ROOM, "night": true, "effect": "wind", "params": {"strength": 0.006}, "placeholder": "(lamp room, no light)", "seconds": 1.8},
	{"same_image": true, "text": "they were right, the lamp...", "seconds": 2.5},
	{"text": "you fixed the lamp", "seconds": 2.0},
	{"scene": LAMP_ROOM, "effect": "wind", "params": {"strength": 0.006}, "placeholder": "(lamp room, lit)", "seconds": 1.8},
	{"same_image": true, "text": "the wind blew too fast", "params": {"strength": 0.03}, "seconds": 2.5},
	{"same_image": true, "text": "you slipped", "seconds": 2.0},
	{"text": "you fell down", "seconds": 2.0},
	{"text": "you died lmao L bozo", "seconds": 2.5},
]

const LAMP_NO = [
	{"text": "(the whale sings, in a very angelic tune)", "seconds": 3.5},
]

const BINOCULARS = [
	{"scene": RADIO_ROOM, "night": true, "placeholder": "(radio room)", "seconds": 1.2},
	{"scene": BEDROOM, "night": true, "placeholder": "(bedroom)", "seconds": 1.2},
	{"text": "you saw the fleets", "seconds": 2.5},
	{"scene": BEDROOM, "night": true, "placeholder": "(bedroom)", "seconds": 1.2},
	{"scene": RADIO_ROOM, "night": true, "placeholder": "(radio room)", "seconds": 1.2},
]

# radio dialogue lines can call these: {"montage": "binoculars"}
const MONTAGES = {
	"binoculars": BINOCULARS,
}

# every day looks like this unless DAYS says otherwise
const DEFAULT_DAY = {
	"tasks": [],                               # empty = picked automatically (see default_tasks)
	"blocked": [],                      # greyed out, NOT needed to end the day
	"radio_title": "Daily radio call",
	"after_radio": "end_day",           # "end_day", "dock_optional", "dock_forced"
	"arrival_event": [],                # montage the first time she enters the radio room today
	"night": [{"text": "(sleeping...)", "seconds": 2.0}],
	"wake": [{"text": "(you woke up)", "seconds": 1.5}],
	"death": [],                        # montage after the dock walk
	"freq52": "",                        # after the radio: "", "optional" or "forced"
	"lamp_choice": false,                      # after the radio: "turn the lamp brighter?" yes/no
	"storm": false,                            # true = the whole day looks and acts like night
}

# key = "loop_day". only write what is DIFFERENT from DEFAULT_DAY
# key = "loop_day". Only write what is DIFFERENT from DEFAULT_DAY
# "tasks": normal tasks first, "radio" ALWAYS last
const DAYS = {
	"1_1": {
		"tasks": ["make_bed", "change_lamp", "radio"],
		"night": VISION_1,
	},
	"1_2": {
		"tasks": ["extra_task_1", "radio"],
		"arrival_event": HEADACHE_L1_D2,
		"death": DEATH_L1_D2,
	},
	"1_3": {
		"tasks": ["make_bed", "change_lamp", "radio"],
	},
	"1_4": {
		"tasks": ["charge_radio", "extra_task_2", "make_bed", "radio"],
		"blocked": ["battery", "lamp", "kettle"],   # storm
		"radio_title": "[DISTRESS] Daily radio call",
		"death": DEATH_L1_D4,
		"storm" : true,
	},
	"2_1": {
		"tasks": ["charge_radio", "make_bed", "radio"],
		"freq52": "optional",
		"wake": [{"text": "(LOOP 2, day 1. you woke up again.)", "seconds": 3.0}],
	},
	"2_2": {
		"tasks": ["extra_task_2", "radio"],
		"freq52": "optional",
	},
	"2_3": {
		"tasks": ["change_lamp", "extra_task_1", "make_bed", "radio"],
		"freq52": "forced",
	},
	"2_4": {
		"tasks": ["charge_radio", "change_lamp", "extra_task_1", "radio"],
		"blocked": ["charge_radio", "change_lamp", "extra_task_1"],
		"radio_title": "[DISTRESS] Daily radio call",
		"lamp_choice": true,
		"lamp_yes": LAMP_YES,
		"lamp_no": LAMP_NO,
		"storm" : true,
	},
	"3_1": {
		"tasks": ["charge_radio", "make_bed", "radio"],
		"freq52": "optional",
		"wake": [{"text": "(LOOP 3, day 1. you woke up again.)", "seconds": 3.0}],
	},
	"3_2": {
		"tasks": ["extra_task_2", "radio"],
		"freq52": "optional",
	},
	"3_3": {
		"tasks": ["change_lamp", "extra_task_1", "make_bed", "radio"],
		"freq52": "forced",
	},
	"3_4": {
		"tasks": ["charge_radio", "change_lamp", "extra_task_1", "radio"],
		"blocked": ["charge_radio", "change_lamp", "extra_task_1"],
		"radio_title": "[DISTRESS] Daily radio call",
		"lamp_choice": true,
		"lamp_yes": LAMP_YES,
		"lamp_no": LAMP_NO,
		"storm" : true,
	},
}


static func get_day(loop_number, day_number):
	var data = DEFAULT_DAY.duplicate()
	var key = str(loop_number) + "_" + str(day_number)
	if DAYS.has(key):
		data.merge(DAYS[key], true)
	if data["tasks"].size() == 0:
		data["tasks"] = default_tasks(day_number)
	return data


# days without their own "tasks": 2 or 3 tasks that rotate through the 6, then the radio
static func default_tasks(day_number):
	var ids = TASKS.keys()
	var result = []
	for i in range(2 + day_number % 2):
		result.append(ids[(day_number * 2 + i) % ids.size()])
	result.append("radio")
	return result


# tasks that must be done before the day can end
static func required_tasks(loop_number, day_number):
	var data = get_day(loop_number, day_number)
	var result = []
	for task_id in data["tasks"]:
		if not data["blocked"].has(task_id):
			result.append(task_id)
	return result
# lamp off = the dark staircase and dark lamp room. Edit this one line to change when
static func lamp_off(loop_number, day_number):
	return loop_number == 2

static func task_def(task_id):
	if task_id == "radio":
		return RADIO_CALL
	return TASKS[task_id]


# the tasks she can do right now at this object (room scene path + spot node name)
static func tasks_at(loop_number, day_number, room_path, spot_name):
	var data = get_day(loop_number, day_number)
	var others_done = true
	for other in required_tasks(loop_number, day_number):
		if other != "radio" and not GameState.is_task_done(other):
			others_done = false
	var result = []
	for task_id in data["tasks"]:
		if GameState.is_task_done(task_id) or data["blocked"].has(task_id):
			continue
		if task_id == "radio" and not others_done:
			continue   # the call comes last
		var def = task_def(task_id)
		if def["room"] == room_path and def["spots"].has(spot_name):
			result.append(task_id)
	return result
static func inspect_steps(action):
	if INSPECT_IMAGES.has(action):
		var time_of_day = "day"
		if GameState.is_night:
			time_of_day = "night"
		# the INSPECT text only shows if the picture file is missing
		return [{"image": INSPECT_IMAGES[action][time_of_day],
				"placeholder": INSPECT.get(action, ""), "seconds": 3.0}]
	if INSPECT.has(action):
		return [{"text": INSPECT[action], "seconds": 3.0}]
	return []
