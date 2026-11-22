extends TextureButton

# the room listens to these two shouts
signal hovered(spot)
signal unhovered(spot)

# the choice texts the player sees, and what each one does
# (the first text goes with the first action, and so on)
@export var choice_texts: Array[String] = []
@export var choice_actions: Array[String] = []

# where the text appears. (0, 0) means right under the object's bottom-left corner
@export var menu_offset = Vector2(0, 0)

# big areas like the floor: show the text next to the mouse instead
@export var menu_follows_mouse = false

# the same picture as the object, with a white edge.
# Leave it empty to use the plain white box instead
@export var outline_texture: Texture2D

@onready var fill = $Fill
@onready var outline_box = $OutlineBox
@onready var outline_image = $OutlineImage


func _ready():
	# connect the mouse FIRST, so a problem further down can't stop it
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)
	print("spot ready: ", name, " size: ", size)  # TEMPORARY
	focus_mode = Control.FOCUS_NONE
	# no picture yet: show the pale placeholder box
	fill.visible = (texture_normal == null)
	outline_box.hide()
	outline_image.hide()
	outline_image.texture = outline_texture
	make_click_shape()


# the clickable area follows the object's picture (transparent parts do not count)
func make_click_shape():
	if texture_normal == null:
		return  # no picture yet: the whole box is clickable
	var image = texture_normal.get_image()
	if image == null:
		print("no image to read for ", name, ", the whole box is clickable")
		return
	if image.is_compressed():
		image.decompress()
	var mask = BitMap.new()
	mask.create_from_image_alpha(image, 0.1)
	if mask.get_true_bit_count() == 0:
		print("picture of ", name, " is fully transparent, the whole box is clickable")
		return
	texture_click_mask = mask


func on_mouse_entered():
	print("hover: ", name)  # TEMPORARY
	hovered.emit(self)


func on_mouse_exited():
	unhovered.emit(self)


func show_outline():
	if outline_texture != null:
		outline_image.show()
	else:
		outline_box.show()


func hide_outline():
	outline_box.hide()
	outline_image.hide()


func get_menu_position():
	if menu_follows_mouse:
		return get_global_mouse_position() + Vector2(20, -70)
	return global_position + Vector2(0, size.y) + menu_offset
