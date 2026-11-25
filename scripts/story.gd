class_name Story
extends RefCounted

const RADIO_ROOM = "res://scenes/world/radio_room.tscn"

const BEDROOM = "res://scenes/world/bedroom.tscn"
const BEDROOM_BACK = "res://scenes/world/bedroom_back.tscn"
const FIRST_FLOOR = "res://scenes/world/first_floor_room.tscn"
const OUTSIDE = "res://scenes/world/outside.tscn"
const DOCK = "res://scenes/world/dock.tscn"   # doesn't exist yet -> shows placeholder text

# the 6 unique tasks. "scene" = the popup scene the other programmer makes ("" = click finishes it)
const TASKS = {
	"bed": {"title": "Make the bed", "scene": ""},
	"battery": {"title": "Charge the radio battery", "scene": ""},
	"labels": {"title": "Change the storage labels", "scene": ""},
	"lamp": {"title": "Clean the lamp lens", "scene": ""},
	"logbook": {"title": "Fill in the logbook", "scene": ""},
	"kettle": {"title": "Boil water for tea", "scene": ""},
}

# montage step keys: "text" (always shown), "placeholder" (shown only if no picture),
# "scene" (uses that room's Background), "image" (res:// path), "sound", "seconds" (default 1.5)

const WALK_TO_DOCK = [
	{"scene": BEDROOM, "placeholder": "(bedroom)", "seconds": 1.3},
	{"scene": BEDROOM_BACK, "placeholder": "(bedroom, looking behind - placeholder)", "seconds": 1.3},
	{"scene": FIRST_FLOOR, "placeholder": "(first floor - placeholder)", "seconds": 1.3},
	{"scene": OUTSIDE, "placeholder": "(outside)", "seconds": 1.3},
	{"scene": DOCK, "placeholder": "(the dock - placeholder)", "seconds": 1.5},
]

const DEATH_L1_D2 = [
	{"text": "(img 1: she looks for the whale eyes that are not there)", "seconds": 2.0},
	{"text": "(img 2: a flash of the eyes, then gone. back to img 1)", "seconds": 2.0},
	{"text": "(img 3: she slips into the sea, her face frozen in fear)", "seconds": 2.0},
	{"text": "you died.", "seconds": 2.0},
]

const DEATH_L1_D4 = [
	{"text": "(img 1: her, front facing, hypnotized eyes)", "seconds": 2.0},
	{"text": "(img 2: her silhouette on the edge of the dock, 8-10 whales leap around her)\n*whale screech*", "seconds": 2.5},
	{"text": "you died.", "seconds": 2.0},
]

const HEADACHE_L1_D2 = [
	{"text": "you felt a strange headache...", "seconds": 2.5},
	{"text": "(img 1: she opens the door)", "seconds": 1.8},
	{"text": "(img 2: running through the shrubs)", "seconds": 1.8},
	{"text": "(img 3: panting on the dock, a pair of eyes looks at her)", "seconds": 2.2},
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
}

# key = "loop_day". only write what is DIFFERENT from DEFAULT_DAY
# key = "loop_day". Only write what is DIFFERENT from DEFAULT_DAY
# "tasks": normal tasks first, "radio" ALWAYS last
const DAYS = {
	"1_1": {
		"tasks": ["bed", "battery", "radio"],
		"night": VISION_1,
	},
	"1_2": {
		"tasks": ["labels", "lamp", "logbook", "radio"],
		"arrival_event": HEADACHE_L1_D2,
		"after_radio": "dock_optional",
		"death": DEATH_L1_D2,
	},
	"1_3": {
		"tasks": ["kettle", "bed", "radio"],
	},
	"1_4": {
		"tasks": ["battery", "lamp", "kettle", "radio"],
		"blocked": ["battery", "lamp", "kettle"],   # storm
		"radio_title": "[DISTRESS] Daily radio call",
		"after_radio": "dock_forced",
		"death": DEATH_L1_D4,
	},
	"2_1": {
		"wake": [{"text": "(LOOP 2, day 1. you woke up again.)\n(loop 2 is not written yet, default days)", "seconds": 3.0}],
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
