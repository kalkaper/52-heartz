extends TextureButton

@export var hover_scale: Vector2 = Vector2(1.1, 1.1)
@export var press_scale: Vector2 = Vector2(0.95, 0.95)
@export var animation_speed: float = 0.1

func _ready() -> void:
	# 1. Create the pixel-accurate click mask from the Normal texture
	if texture_normal:
		var image: Image = texture_normal.get_image()
		var bitmap: BitMap = BitMap.new()
		# 0.1 means any pixel with >10% opacity counts as part of the hitbox
		bitmap.create_from_image_alpha(image, 0.1)
		texture_click_mask = bitmap
	
	# 2. Center the pivot offset so the button scales from its middle, not top-left
	# Wait one frame to ensure container/layout sizing has finished
	await get_tree().process_frame
	pivot_offset = size / 2.0
	
	# 3. Connect signals for hover and press states
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

func _on_mouse_entered() -> void:
	_animate_scale(hover_scale)

func _on_mouse_exited() -> void:
	_animate_scale(Vector2.ONE)

func _on_button_down() -> void:
	_animate_scale(press_scale)

func _on_button_up() -> void:
	# Return to hover scale if mouse is still over the button, otherwise normal
	if is_hovered():
		_animate_scale(hover_scale)
	else:
		_animate_scale(Vector2.ONE)

func _animate_scale(target_scale: Vector2) -> void:
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", target_scale, animation_speed)
