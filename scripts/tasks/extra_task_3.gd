extends Control

@onready var slider_bar: ColorRect = $Slider/SliderBar
@onready var slider_track: ColorRect = $Slider/SliderTrack
@onready var slider_filled: ColorRect = $Slider/SliderFilled
@onready var slider_target: ColorRect = $Slider/SliderTarget
@onready var success_label: Label = $Success

var drag_offset := Vector2.ZERO
var drag_start_pos := Vector2.ZERO
var is_dragged = false

func _ready() -> void:
	success_label.hide()
	slider_bar.gui_input.connect(_on_click)

func _on_click(event: InputEvent) -> void:
	if(event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed):
		is_dragged = true
		drag_offset = slider_bar.position - get_global_mouse_position()
		slider_bar.move_to_front()

func _input(event: InputEvent) -> void:
	if(event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and not event.pressed):
		is_dragged = false

func _process(delta: float) -> void:
	if(is_dragged):
		slider_bar.position = get_global_mouse_position() + drag_offset
		slider_bar.position.x = 1000
		slider_bar.position.y = min(slider_bar.position.y, 816)
		slider_bar.position.y = max(slider_bar.position.y, 320)
		slider_filled.size.y = (832 - slider_bar.position.y)
		slider_filled.position.y = slider_bar.position.y
	else:
		var zone := slider_target.get_global_rect()
		var center := slider_bar.global_position + Vector2(0, 16)

		if zone.has_point(center):
			slider_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE # locked, cant be picked up again
			success_label.show()
