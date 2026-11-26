extends Control

# main.gd listens to this one
signal day_ended
signal dock_chosen   # she said YES to "Go to the dock?"
signal radio_finished   # main.gd turns the room into night
signal loop_ended(key)        # "lamp_yes" or "lamp_no"
signal radio_montage(key)     # a dialogue line asked for a montage


var page_names = ["menu", "start", "tasks", "log"]
var current = 1
var radio_playing = false
var in_task = false   # a task popup is open
var awaiting_52 = false      # the 52 Hz question is waiting for her answer
var awaiting_lamp = false
var radio_mode = "normal"
var popup_waiting_click = false
var current_popup = null
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
@onready var book = $Book

const NORMAL_FONT = "res://assets/fonts/normal.otf"   # change to your normal font file


func use_normal_font(node):
	if ResourceLoader.exists(NORMAL_FONT):
		node.add_theme_font_override("font", load(NORMAL_FONT))
		
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
	use_normal_font($Book/Pages/EndDayPage/EndDayBox/ButtonChoices/YesButton/YesButtonLabel)
	use_normal_font($Book/Pages/EndDayPage/EndDayBox/ButtonChoices/NoButton/NoButtonLabel)
	use_normal_font($RadioTaskView/ContinueButton/ContinueButtonLabel)
	use_normal_font(get_node("RadioTaskView/52HzButton"))
	use_normal_font(close_button)
	radio.montage_requested.connect(on_radio_montage_requested)
	
func on_radio_montage_requested(key):
	radio_montage.emit(key)
	
		
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
		if task_page.are_all_done() and (end_prompt_wanted or awaiting_52 or awaiting_lamp):
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

# the radio object starts the daily call, which plays inside the journal book
func open_for_radio():
	show_page(2)
	show()
	start_radio()
	
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
	if awaiting_lamp:
		return "lamp"
	if awaiting_52:
		return "freq52_" + Story.get_day(GameState.loop, GameState.day)["freq52"]
	var after = Story.get_day(GameState.loop, GameState.day)["after_radio"]
	# said NO to the dock -> becomes the normal "End the day?"
	if after == "dock_optional" and GameState.day_flags.has("dock_declined"):
		return "end_day"
	return after


func on_end_day_confirmed():
	if current_prompt() == "lamp":
		awaiting_lamp = false
		close()
		loop_ended.emit("lamp_yes")
		return
	if current_prompt().begins_with("freq52"):
		awaiting_52 = false
		end_day_page.hide()
		start_radio("52")
		return
	var mode = current_prompt()
	close()
	if mode == "end_day":
		day_ended.emit()
	else:
		dock_chosen.emit()


func on_end_day_cancelled():
	if current_prompt() == "lamp":
		awaiting_lamp = false
		end_day_page.hide()
		start_radio("52")
		return
	if current_prompt() == "freq52_optional":
		awaiting_52 = false
		end_day_page.hide()
		finish_radio_day()
		return
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
# a task popup scene needs ONE thing: a `signal completed`
func start_task_popup(task_id, scene_path):
	var popup = load(scene_path).instantiate()
	if not popup.has_signal("completed"):
		print("Task scene has no 'completed' signal: ", scene_path)
		popup.free()
		task_page.mark_done(task_id)
		return
	in_task = true
	book.hide()
	prev_button.hide()
	next_button.hide()
	close_button.hide()
	get_parent().add_child(popup)   # next to the journal, so it doesn't inherit the journal font
	current_popup = popup
	popup.completed.connect(on_task_popup_completed.bind(task_id))


func on_task_popup_completed(task_id):
	task_page.mark_done(task_id)   # struck through in the list
	var hint = Label.new()
	hint.text = "click anywhere to continue"
	hint.position = Vector2(700, 1000)
	hint.add_theme_font_size_override("font_size", 36)
	current_popup.add_child(hint)
	# wait a moment so the click that finished the task doesn't also skip this
	await get_tree().create_timer(0.4).timeout
	popup_waiting_click = true


# after a task is done, any left click leaves it
func _input(event):
	if popup_waiting_click and event is InputEventMouseButton \
			and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		popup_waiting_click = false
		get_viewport().set_input_as_handled()
		leave_task_popup()


func leave_task_popup():
	current_popup.queue_free()
	current_popup = null
	in_task = false
	book.show()
	prev_button.show()
	next_button.show()
	close_button.show()
	close()   # back to the room. to go back to the journal instead, use: show_page(2)

func start_radio(mode = "normal"):
	radio_mode = mode
	radio_playing = true
	pages_holder.hide()
	prev_button.hide()
	next_button.hide()
	close_button.hide()
	radio.start(GameState.loop, GameState.day, mode)


func on_radio_finished():
	radio_playing = false
	pages_holder.show()
	prev_button.show()
	next_button.show()
	close_button.show()
	var data = Story.get_day(GameState.loop, GameState.day)
	if radio_mode == "normal":
		task_page.mark_done("radio")
		awaiting_52 = (data["freq52"] != "")
		awaiting_lamp = data["lamp_choice"]
	show_page(2)
	if awaiting_52 or awaiting_lamp:
		return   # a question is on the page now
	finish_radio_day()


# the day's radio part is over: dock, the end of the loop, or the night begins
func finish_radio_day():
	if radio.day_choices.has("dock_yes"):
		close()
		dock_chosen.emit()
		return
	if radio_mode == "52" and Story.get_day(GameState.loop, GameState.day)["lamp_choice"]:
		close()
		loop_ended.emit("lamp_no")
		return
	radio_finished.emit()

# Esc closes the journal
func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE and visible and not radio_playing:
			close()
