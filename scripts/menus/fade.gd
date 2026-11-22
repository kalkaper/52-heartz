extends ColorRect


# turns the screen fully black right away
func set_black():
	color.a = 1.0


# slowly goes to black
func fade_out(seconds):
	var tween = create_tween()
	tween.tween_property(self, "color:a", 1.0, seconds)
	await tween.finished


# slowly goes back to the picture
func fade_in(seconds):
	var tween = create_tween()
	tween.tween_property(self, "color:a", 0.0, seconds)
	await tween.finished
