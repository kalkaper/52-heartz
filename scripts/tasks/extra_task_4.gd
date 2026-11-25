extends Control

@onready var success_label: Label = $Success
@onready var warning_label: Label = $Warning
@onready var card: ColorRect = $Card

var grab_offset = Vector2.ZERO
var last_position = Vector2.ZERO
var initial_position = Vector2.ZERO
var is_dragging = false
var time_sum = 0.0
var max_velocity = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	success_label.hide()
	card.gui_input.connect(_on_click)
	last_position = card.position
	initial_position = card.position

func _on_click(event: InputEvent) -> void:
	if(event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT):
		is_dragging = event.pressed
		if(is_dragging):
			grab_offset = get_global_mouse_position() - card.position	

func _process(delta: float) -> void:
	if(is_dragging):
		card.position = get_global_mouse_position() - grab_offset
		card.position.y = 320
		card.position.x = min(card.position.x, 1216)
		card.position.x = max(card.position.x, 576)
		var velocity = (card.position - last_position) / delta
		max_velocity = max(max_velocity, velocity.x)
		time_sum += delta
		last_position = card.position
		#print(velocity)
	else:
		if(time_sum != 0.0):
			var average_velocity = 640 / time_sum
			print(card.position.x)
			print(average_velocity)
			if(card.position.x != 1216.0):
				warning_label.text = "Swipe all the way through!"
			elif(average_velocity < 640):
				warning_label.text = "Swipe faster!"
			elif(average_velocity > 1280 or max_velocity > 1920):
				warning_label.text = "Swipe slower!"
			else:
				warning_label.hide()
				success_label.show()
				card.mouse_filter = Control.MOUSE_FILTER_IGNORE
				initial_position = card.position
			time_sum = 0.0
			max_velocity = 0.0
		card.position = initial_position
