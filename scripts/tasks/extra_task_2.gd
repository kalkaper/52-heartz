extends Control

@onready var success_label: Label = $Success
@onready var task_label: Label = $Task
@onready var current_frequency_label: Label = $CurrentFrequency
@onready var slider_bar: ColorRect = $Slider/SliderBar

signal completed   # the journal listens to this

# --- where the bar can move. Edit these two numbers to fit the dial ---
const BAR_Y = 382.0     # the bar's Position Y
const MIN_X = 519.0     # the bar's Position X when it sits on the 88 MHz end
const MAX_X = 1215.0    # the bar's Position X when it sits on the 108 MHz end
const MIN_FREQ = 88.0
const MAX_FREQ = 108.0

var finished = false
var drag_offset := Vector2.ZERO
var is_dragged = false
var target_frequency = randi_range(92, 107)


func finish():
	if finished:
		return
	finished = true
	completed.emit()


func _ready() -> void:
	success_label.hide()
	slider_bar.gui_input.connect(_on_click.bind(slider_bar))
	$Task.text = "Set the frequency to %d MHz" % target_frequency


# the slider bar can be moved by dragging with left click
func _on_click(event: InputEvent, bar: ColorRect) -> void:
	if(event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed):
		is_dragged = true
		drag_offset = slider_bar.global_position - get_global_mouse_position()
		bar.move_to_front()


# the bar's x position -> a frequency between 88 and 108
func current_frequency() -> int:
	var t = (slider_bar.position.x - MIN_X) / (MAX_X - MIN_X)
	return roundi(MIN_FREQ + t * (MAX_FREQ - MIN_FREQ))


func _process(delta: float) -> void:
	if(is_dragged):
		slider_bar.position = get_global_mouse_position() + drag_offset
		slider_bar.position.y = BAR_Y
		slider_bar.position.x = clamp(slider_bar.position.x, MIN_X, MAX_X)
		current_frequency_label.text = "Current frequency: %d MHz" % current_frequency()
	elif(not finished and current_frequency() == target_frequency):
		success_label.show()
		slider_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		finish()


# if released
func _input(event: InputEvent) -> void:
	if(is_dragged \
			and event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and not event.pressed):
		is_dragged = false
