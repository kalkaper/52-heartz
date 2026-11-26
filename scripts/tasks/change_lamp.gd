extends Control

@onready var old_lamp: ColorRect = $OldLamp
@onready var new_lamp: ColorRect = $NewLamp
@onready var lamp_slot: ColorRect = $LampSlot
@onready var success_label: Label = $Success

var dragged: ColorRect = null
var drag_offset := Vector2.ZERO
var drag_start_pos := Vector2.ZERO

signal completed   # the journal listens to this
var finished = false


func finish():
	if finished:
		return
	finished = true
	completed.emit()

func _ready() -> void:
	success_label.hide()
	old_lamp.mouse_filter = Control.MOUSE_FILTER_STOP
	old_lamp.gui_input.connect(_on_item_gui_input.bind(old_lamp))
	new_lamp.mouse_filter = Control.MOUSE_FILTER_STOP
	new_lamp.gui_input.connect(_on_item_gui_input.bind(new_lamp))


# if the lamp is currently held by left click
func _on_item_gui_input(event: InputEvent, lamp: ColorRect) -> void:
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		dragged = lamp
		drag_offset = lamp.global_position - get_global_mouse_position()
		drag_start_pos = lamp.global_position
		lamp.move_to_front()

# lamp held by left click can be dragged anywhere
func _process(delta: float) -> void:
	if dragged:
		dragged.global_position = get_global_mouse_position() + drag_offset

# if left click is released
# stop dragging and "drop" the lamp
func _input(event: InputEvent) -> void:
	if dragged and event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_drop(dragged)
		dragged = null
		

func _drop(lamp: ColorRect) -> void:
	var zone := lamp_slot.get_global_rect()
	var center := lamp.global_position + lamp.size / 2.0
	var center2 := old_lamp.global_position + lamp.size / 2.0
	
	# if the lamp slot is empty
	# place the new lamp
	if(zone.has_point(center) and not zone.has_point(center2)):
		lamp.global_position = lamp.global_position.clamp(zone.position, zone.end - lamp.size)
		lamp.mouse_filter = Control.MOUSE_FILTER_IGNORE
		old_lamp.mouse_filter = Control.MOUSE_FILTER_IGNORE
		success_label.show()
		finish()
	# else  if the lamp slot is not empty
	# snap back to its original position
	elif(zone.has_point(center2)):
		lamp.global_position = drag_start_pos
	dragged = null
