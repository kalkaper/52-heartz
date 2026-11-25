@tool
class_name AutoCropTextureButton
extends TextureButton

@export var auto_crop_and_mask: bool = false:
	set(value):
		if value:
			_process_textures()
		auto_crop_and_mask = false

var _base_scale: Vector2
var _base_pos: Vector2
var _tween: Tween

func _ready() -> void:
	if not Engine.is_editor_hint():
		# Guarantee the pixel-accurate click/hover mask exists at runtime
		_rebuild_click_mask()
		
		_base_scale = scale
		_base_pos = position
		
		mouse_entered.connect(func(): _anim_scale(1.08))
		mouse_exited.connect(func(): _anim_scale(1.0))
		button_down.connect(func(): _anim_scale(0.92))
		button_up.connect(func(): _anim_scale(1.08 if is_hovered() else 1.0))

func _process_textures() -> void:
	if not texture_normal:
		return
		
	var img: Image = texture_normal.get_image()
	if not img:
		return
		
	var used_rect: Rect2i = img.get_used_rect()
	if not used_rect.has_area():
		return
		
	var cropped_img: Image = img.get_region(used_rect)
	texture_normal = ImageTexture.create_from_image(cropped_img)
	
	if texture_hover:
		texture_hover = _crop_with_rect(texture_hover, used_rect)
	if texture_pressed:
		texture_pressed = _crop_with_rect(texture_pressed, used_rect)
	if texture_disabled:
		texture_disabled = _crop_with_rect(texture_disabled, used_rect)
		
	custom_minimum_size = used_rect.size
	size = used_rect.size
	_rebuild_click_mask()

func _rebuild_click_mask() -> void:
	if not texture_normal:
		return
	var img: Image = texture_normal.get_image()
	if img and not img.is_empty():
		var bitmap := BitMap.new()
		# 0.5 = ignores transparent and faint anti-aliased pixels
		bitmap.create_from_image_alpha(img, 0.5)
		texture_click_mask = bitmap

func _crop_with_rect(tex: Texture2D, rect: Rect2i) -> ImageTexture:
	var sub_img: Image = tex.get_image()
	if sub_img and sub_img.get_size() >= rect.end:
		return ImageTexture.create_from_image(sub_img.get_region(rect))
	return tex as ImageTexture

func _anim_scale(mult: float) -> void:
	if _tween:
		_tween.kill()
	var target_scale := _base_scale * mult
	var target_pos := _base_pos - (size * (target_scale - _base_scale) * 0.5)
	
	_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", target_scale, 0.1)
	_tween.tween_property(self, "position", target_pos, 0.1)
