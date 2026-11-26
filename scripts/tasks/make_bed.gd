extends Control

@onready var bed: ColorRect = $Bed
@onready var trash_bin: ColorRect = $TrashBin
@onready var placed_label: Label = $PlacedCount
signal completed   # the journal listens to this
var finished = false


func finish():
	if finished:
		return
	finished = true
	completed.emit()
var items: Array[TextureRect] = []
var placed_count := 0

var dragged: TextureRect = null
var drag_offset := Vector2.ZERO
var drag_start_pos := Vector2.ZERO

func _ready() -> void:
	for child in $Trashes.get_children():
		var tex := child as TextureRect
		tex.mouse_filter = Control.MOUSE_FILTER_STOP
		tex.gui_input.connect(_on_item_gui_input.bind(tex))
		items.append(tex)

# if the trash is currently held by left click
func _on_item_gui_input(event: InputEvent, tex: TextureRect) -> void:
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		dragged = tex
		drag_offset = tex.global_position - get_global_mouse_position()
		drag_start_pos = tex.global_position
		tex.move_to_front()

# trash held by left click can be dragged anywhere
func _process(_delta: float) -> void:
	if dragged:
		dragged.global_position = get_global_mouse_position() + drag_offset

# if left click is released
# stop dragging the trash
func _input(event: InputEvent) -> void:
	if dragged and event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_drop(dragged)
		dragged = null

# if trash is dropped in trash bin
# it will stay there
# otherwise, it can be dragged anywhere
func _drop(tex: TextureRect) -> void:
	var zone := trash_bin.get_global_rect()
	var center := tex.global_position

	if zone.has_point(center):
		tex.global_position = tex.global_position.clamp(zone.position, zone.end - tex.size)
		tex.mouse_filter = Control.MOUSE_FILTER_IGNORE # locked, cant be picked up again
		placed_count += 1
		placed_label.text = "Placed %d/4" % placed_count
		if(placed_count == 4):
			placed_label.text = "Placed %d/4\nTask complete!" % placed_count
			finish()
