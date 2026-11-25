extends Control

signal confirmed
signal cancelled

@onready var question = $EndDayBox/Question
@onready var yes_button = $EndDayBox/ButtonChoices/YesButton
@onready var no_button = $EndDayBox/ButtonChoices/NoButton


func _ready():
	yes_button.pressed.connect(on_yes_pressed)
	no_button.pressed.connect(on_no_pressed)
	# the task list stays visible above, so move the question a bit lower
	$EndDayBox.offset_top += 40
	$EndDayBox.offset_bottom += 40


# mode: "end_day", "dock_optional" (yes/no), "dock_forced" (only yes)
func setup(mode):
	if mode == "dock_optional":
		question.text = "Go To The Dock?"
		no_button.show()
	elif mode == "dock_forced":
		question.text = "Go To The Dock?"
		no_button.hide()
	else:
		question.text = "End The Day?"
		no_button.show()


func on_yes_pressed():
	confirmed.emit()


func on_no_pressed():
	cancelled.emit()
