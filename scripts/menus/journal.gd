extends Control

var page_names = ["menu", "start", "tasks", "log"]
var current = 1

@onready var pages = {
	"menu": $Book/Pages/MenuPage,
	"start": $Book/Pages/StartPage,
	"tasks": $Book/Pages/TaskPage,
	"log": $Book/Pages/LogPage
}
@onready var prev_button = $PrevButton
@onready var next_button = $NextButton
@onready var close_button = $CloseButton


func _ready():
	prev_button.pressed.connect(go_prev)
	next_button.pressed.connect(go_next)
	close_button.pressed.connect(close)
	$Book/Pages/EndDayPage.hide()
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
	for key in pages:
		pages[key].visible = (key == page_names[current])
	prev_button.text = page_names[prev_index()].capitalize()
	next_button.text = page_names[next_index()].capitalize()


func go_prev():
	show_page(prev_index())


func go_next():
	show_page(next_index())


func close():
	hide()
	show_page(1)


# temporary test keys, delete when the top bar button works
func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_J and not visible:
			show()
		elif event.keycode == KEY_ESCAPE and visible:
			close()
