extends Control

@onready var success_label: Label = $Success
@onready var task_label: Label = $Task
@onready var current_frequency_label: Label = $CurrentFrequency
@onready var slider_bar: ColorRect = $Slider/SliderBar

var drag_offset := Vector2.ZERO
var drag_start_pos := Vector2.ZERO
var is_dragged = false
var target_frequency = randi_range(92, 109)

# set the target frequency
# ranging from 92 to 108
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

# the position of the slider bar is limited
# to the slider track
func _process(delta: float) -> void:
	if(is_dragged):
		slider_bar.position = get_global_mouse_position() + drag_offset
		slider_bar.position.y = 570.0
		if(slider_bar.position.x < 360.0):
			slider_bar.position.x = 360.0
		if(slider_bar.position.x > 1560.0):
			slider_bar.position.x = 1560.0
		var current_frequency: int = roundi(88.0 + (slider_bar.position.x  - 360.0)/60.0)
		current_frequency_label.text = "Current frequency: %d MHz" % current_frequency
	elif(roundi(88.0 + (slider_bar.position.x  - 360.0)/60.0) == target_frequency):
		success_label.show()
		slider_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		is_dragged = false

# if released
func _input(event: InputEvent) -> void:
	if(is_dragged \
			and event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and not event.pressed):
		is_dragged = false
