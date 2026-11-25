extends TextureButton

# the room listens to these two shouts
signal hovered(spot)
signal unhovered(spot)

# the choice texts the player sees, and what each one does
# (the first text goes with the first action, and so on)
@export var choice_texts: Array[String] = []
@export var choice_actions: Array[String] = []

# the text appears to the RIGHT of the drawn part of the object.
# this moves it more: x moves it right (negative = left), y moves it down
@export var menu_offset = Vector2(0, 0)

# how thick the white edge is, in picture pixels
@export var outline_thickness = 4.0

# hover scale settings
@export var hover_scale = Vector2(1.08, 1.08)
@export var scale_duration = 0.12

@onready var fill = $Fill
@onready var outline_box = $OutlineBox

var outline_material = null
var base_scale = Vector2.ONE
var scale_tween: Tween

# the box around the DRAWN pixels, measured in the picture's own pixels
var drawn_area = Rect2()


func _ready():
	# connect the mouse FIRST, so a problem further down can't stop it
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)
	focus_mode = Control.FOCUS_NONE
	outline_box.hide()
	
	# remember starting scale and center the pivot without shifting visual position
	base_scale = scale
	var old_pivot = pivot_offset
	pivot_offset = size / 2.0
	position += (pivot_offset - old_pivot) * (scale - Vector2.ONE)
	
	if texture_normal == null:
		# no picture yet: pale box, and a plain frame as the outline
		fill.show()
		return
	# there is a picture: no placeholder box
	fill.hide()
	var image = texture_normal.get_image()
	if image == null:
		print("no image to read for ", name)
		return
	if image.is_compressed():
		image.decompress()
	drawn_area = Rect2(image.get_used_rect())
	make_click_shape(image)
	make_outline_material()


# the clickable area follows the object's picture (transparent parts do not count)
func make_click_shape(image):
	var mask = BitMap.new()
	mask.create_from_image_alpha(image, 0.1)
	if mask.get_true_bit_count() == 0:
		print("picture of ", name, " is fully transparent, the whole box is clickable")
		return
	texture_click_mask = mask


# gives this spot its own outline shader (turned off until we hover)
func make_outline_material():
	outline_material = ShaderMaterial.new()
	outline_material.shader = load("res://assets/shaders/outline.gdshader")
	outline_material.set_shader_parameter("width", outline_thickness)
	outline_material.set_shader_parameter("outline_on", false)
	material = outline_material


# the drawn part of the object, in screen coordinates (follows position and scale)
func get_drawn_rect():
	var local_top_left = Vector2.ZERO
	var local_size = size
	if texture_normal != null and drawn_area.size != Vector2.ZERO:
		# the picture may be drawn bigger or smaller than its own pixels
		var ratio = size / texture_normal.get_size()
		local_top_left = drawn_area.position * ratio
		local_size = drawn_area.size * ratio
	var t = get_global_transform()
	var top_left = t * local_top_left
	var bottom_right = t * (local_top_left + local_size)
	return Rect2(top_left, bottom_right - top_left)


func on_mouse_entered():
	animate_scale(base_scale * hover_scale)
	hovered.emit(self)


func on_mouse_exited():
	animate_scale(base_scale)
	unhovered.emit(self)


func animate_scale(target: Vector2):
	if scale_tween:
		scale_tween.kill()
	scale_tween = create_tween()
	scale_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(self, "scale", target, scale_duration)


func show_outline():
	if outline_material != null:
		outline_material.set_shader_parameter("outline_on", true)
	else:
		outline_box.show()


func hide_outline():
	if outline_material != null:
		outline_material.set_shader_parameter("outline_on", false)
	outline_box.hide()


func get_menu_position():
	var rect = get_drawn_rect()
	# right side of the drawn part, level with its vertical middle
	var x = rect.position.x + rect.size.x + 20
	var y = rect.position.y + rect.size.y / 2.0
	return Vector2(x, y) + menu_offset
