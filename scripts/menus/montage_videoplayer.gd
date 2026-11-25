extends Control

# await montage.play(list_of_steps). Click skips the current step.

@onready var image = $Image
@onready var audio = $Audio

var black = null
var caption = null
var skip_requested = false


func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	black = ColorRect.new()
	black.color = Color(0, 0, 0, 1)
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(black)
	move_child(black, 0)
	black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	caption = Label.new()
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caption.add_theme_font_size_override("font_size", 48)
	caption.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	caption.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	caption.add_theme_constant_override("outline_size", 12)
	add_child(caption)
	caption.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	caption.offset_left = 160
	caption.offset_right = -160
	hide()


func play(steps):
	show()
	mouse_filter = Control.MOUSE_FILTER_STOP
	for step in steps:
		show_step(step)
		skip_requested = false
		var seconds = step.get("seconds", 1.5)
		var elapsed = 0.0
		while elapsed < seconds and not skip_requested:
			await get_tree().process_frame
			elapsed += get_process_delta_time()
	audio.stop()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	hide()


func show_step(step):
	var texture = find_texture(step)
	image.texture = texture
	image.material = make_effect(step.get("effect", ""))
	image.visible = (texture != null)
	var words = step.get("text", "")
	if texture == null and step.has("placeholder"):
		if words != "":
			words += "\n"
		words += step["placeholder"]
	caption.text = words
	if step.has("sound") and ResourceLoader.exists(step["sound"]):
		audio.stream = load(step["sound"])
		audio.play()


func find_texture(step):
	if step.has("image") and ResourceLoader.exists(step["image"]):
		return load(step["image"])
	if step.has("scene") and ResourceLoader.exists(step["scene"]):
		var room = load(step["scene"]).instantiate()
		var background = room.get_node_or_null("Background")
		var texture = null
		if background is TextureRect:
			texture = background.texture
		room.free()
		return texture
	return null


func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		skip_requested = true

# "effect": "underwater" -> uses res://assets/shaders/underwater.gdshader
func make_effect(effect_name):
	if effect_name == "":
		return null
	var path = "res://assets/shaders/" + effect_name + ".gdshader"
	if not ResourceLoader.exists(path):
		print("No shader file: ", path)
		return null
	var material = ShaderMaterial.new()
	material.shader = load(path)
	return material
