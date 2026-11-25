extends Control

# main.gd listens to this one
signal day_ended
signal dock_chosen   # she said YES to "Go to the dock?"
signal radio_finished   # main.gd turns the room into night

var page_names = ["menu", "start", "tasks", "log"]
var current = 1
var radio_playing = false
var in_task = false   # a task popup is open
var end_prompt_wanted = false   # true only when she came from the bed

@onready var pages = {
	"menu": $Book/Pages/MenuPage,
	"start": $Book/Pages/StartPage,
	"tasks": $Book/Pages/TaskPage,
	"log": $Book/Pages/LogPage
}
@onready var pages_holder = $Book/Pages
@onready var task_page = $Book/Pages/TaskPage
@onready var end_day_page = $Book/Pages/EndDayPage
@onready var radio = $RadioTaskView
@onready var prev_button = $PrevButton
@onready var next_button = $NextButton
@onready var close_button = $CloseButton


func _ready():
	prev_button.pressed.connect(go_prev)
	next_button.pressed.connect(go_next)
	close_button.pressed.connect(close)
	task_page.task_requested.connect(on_task_requested)
	radio.finished.connect(on_radio_finished)
	end_day_page.confirmed.connect(on_end_day_confirmed)
	end_day_page.cancelled.connect(on_end_day_cancelled)
	end_day_page.hide()
	radio.hide()
	show_page(1)


func prev_index():
	if current == 0:
		return page_names.size() - 1
	return current - 1


func next_index():
	if current == page_names.size() - 1:
		return 0
	return current + 1


func show_page(index):
	current = index
	end_day_page.hide()
	for key in pages:
		pages[key].visible = (key == page_names[current])
	#prev_button.text = page_names[prev_index()].capitalize()
	#next_button.text = page_names[next_index()].capitalize()
	if page_names[current] == "tasks":
		task_page.refresh()
		# all done: the list stays (struck through) and the question shows under it
		if task_page.are_all_done() and end_prompt_wanted:
			end_day_page.setup(current_prompt())
			end_day_page.show()


func go_prev():
	end_prompt_wanted = false
	show_page(prev_index())


func go_next():
	end_prompt_wanted = false
	show_page(next_index())


# opens the tasks page WITH the end-day question (main.gd calls this from the bed)
func open_end_page():
	end_prompt_wanted = true
	show_page(2)
	show()


# opens the journal on the start page (the top bar button uses this)
func open():
	show_page(1)
	show()

func close():
	if radio_playing or in_task:
		end_prompt_wanted = false
		return
	hide()
	show_page(1)


# main.gd asks this before letting her sleep
func all_tasks_done():
	return task_page.are_all_done()


# --- End the day ---

# which question the end page asks today
func current_prompt():
	var after = Story.get_day(GameState.loop, GameState.day)["after_radio"]
	# said NO to the dock -> becomes the normal "End the day?"
	if after == "dock_optional" and GameState.day_flags.has("dock_declined"):
		return "end_day"
	return after


func on_end_day_confirmed():
	var mode = current_prompt()
	close()
	if mode == "end_day":
		day_ended.emit()
	else:
		dock_chosen.emit()


func on_end_day_cancelled():
	if current_prompt() == "dock_optional":
		GameState.day_flags["dock_declined"] = true
		show_page(2)   # now shows "End the day?"
		return
	close()


# --- radio ---
func on_task_requested(task_id):
	if task_id == "radio":
		start_radio()
		return
	var scene_path = Story.TASKS[task_id]["scene"]
	if scene_path != "" and ResourceLoader.exists(scene_path):
		start_task_popup(task_id, scene_path)
	else:
		task_page.mark_done(task_id)   # no popup scene yet: clicking finishes it


# a task popup scene needs ONE thing: a `signal completed`, emitted when the player finishes it
func start_task_popup(task_id, scene_path):
	in_task = true
	pages_holder.hide()
	prev_button.hide()
	next_button.hide()
	close_button.hide()
	var popup = load(scene_path).instantiate()
	add_child(popup)
	popup.completed.connect(on_task_popup_completed.bind(task_id, popup))


func on_task_popup_completed(task_id, popup):
	popup.queue_free()
	in_task = false
	pages_holder.show()
	prev_button.show()
	next_button.show()
	close_button.show()
	task_page.mark_done(task_id)
	show_page(2)

func start_radio():
	radio_playing = true
	pages_holder.hide()
	prev_button.hide()
	next_button.hide()
	close_button.hide()
	radio.start(GameState.loop, GameState.day)


func on_radio_finished():
	radio_playing = false
	var in_task = false   # a task popup is open
	pages_holder.show()
	prev_button.show()
	next_button.show()
	close_button.show()
	task_page.mark_done("radio")
	show_page(2)
	radio_finished.emit()


# Esc closes the journal
func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE and visible and not radio_playing:
			close()
