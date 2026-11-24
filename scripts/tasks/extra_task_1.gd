extends Control

@onready var buttons: Control = $Buttons
@onready var success_label: Label = $Success
var colored_button = 0

func _ready() -> void:
	success_label.hide()
	_generate_squares()

# randomly generate at least 3 red squares
func _generate_squares() -> void:
	var generated = false
	while(not generated):
		var cnt = 0
		for child in buttons.get_children():
			if(randi_range(0, 2) == 1):
				child.color = "#ff0000"
				cnt += 1
		if cnt < 3:
			for child in buttons.get_children():
				child.color = "#ffffff"
		else:
			generated = true
			colored_button = cnt
	for child in buttons.get_children():
		if(child.color == Color("#ff0000")):
			child.gui_input.connect(_on_item_click.bind(child))

# if a white square is clicked, do nothing
# otherwise, turn to white square
# if all square is white
# mark task as complete
func _on_item_click(event: InputEvent, rect: ColorRect) -> void:
	if(event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed \
			and rect.color == Color("#ff0000")):
		rect.color = "#ffffff"
		colored_button -= 1
		if(colored_button == 0):
			success_label.show()

func _process(delta: float) -> void:
	pass
