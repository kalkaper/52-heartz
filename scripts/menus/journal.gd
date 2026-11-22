extends Control

var page_names = ["menu", "start", "tasks", "log"]
var current = 1
var radio_playing = false

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
@onready var prev_button_text = $PrevButton/PrevButtonLabel
@onready var next_button_text = $NextButton/NextButtonLabel
@onready var close_button = $CloseButton
@onready var close_button_text = $CloseButton/CloseButtonLabel


func _ready():
	# Ensure child RichTextLabels never intercept mouse clicks
	prev_button_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	next_button_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	close_button_text.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Connect button signals via code
	prev_button.pressed.connect(go_prev)
	next_button.pressed.connect(go_next)
	close_button.pressed.connect(close)

	# Connect task and radio signals
	task_page.task_requested.connect(on_task_requested)
	radio.finished.connect(on_radio_finished)

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
	prev_button_text.text = page_names[prev_index()].capitalize()
	next_button_text.text = page_names[next_index()].capitalize()
	if page_names[current] == "tasks":
		task_page.refresh()
		# when everything is done, the task list is replaced by "End the day?"
		if task_page.are_all_done():
			task_page.hide()
			end_day_page.show()


func go_prev():
	show_page(prev_index())


func go_next():
	show_page(next_index())


func close():
	if radio_playing:
		return
	hide()
	show_page(1)


func on_task_requested(task_id):
	if task_id == "radio":
		start_radio()


func start_radio():
	radio_playing = true
	pages_holder.hide()
	prev_button.hide()
	next_button.hide()
	close_button.hide()
	# later these two numbers come from the game state
	radio.start(1, 1)


func on_radio_finished():
	radio_playing = false
	pages_holder.show()
	prev_button.show()
	next_button.show()
	close_button.show()
	task_page.mark_done("radio")
	show_page(2)

func open():
	show_page(1)
	show()

# Esc closes the journal
func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE and visible and not radio_playing:
			close()
