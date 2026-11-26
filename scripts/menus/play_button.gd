@tool
extends Label


var _base_scale: Vector2
var _base_pos: Vector2
var _tween: Tween

func _ready() -> void:
	if not Engine.is_editor_hint():
		# Guarantee the pixel-accurate click/hover mask exists at runtime
		_base_scale = scale
		_base_pos = position
		
		mouse_entered.connect(func(): _anim_scale(1.08))
		mouse_exited.connect(func(): _anim_scale(1.0))

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
