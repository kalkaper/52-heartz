extends Node

@export var speed := 80.0
const MAX_HEIGHT := 480.0

@onready var button: TextureButton = $ChargeButton
@onready var rect: ColorRect = $Battery
@onready var label: Label = $Label

var holding := false

func _ready() -> void:
	label.hide()
	button.button_down.connect(func(): holding = true)
	button.button_up.connect(func(): holding = false)

# hold the button to increase battery size

func _process(delta: float) -> void:
	if not holding or label.visible:
		return
	var perubahan = min(MAX_HEIGHT - rect.size.y, speed * delta)
	rect.size.y += perubahan
	rect.position.y -= perubahan
	if rect.size.y >= MAX_HEIGHT:
		holding = false
		label.show()
