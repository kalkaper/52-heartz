extends VBoxContainer

# the main scene listens to this shout
signal journal_button_pressed

@onready var day_label = $DayCounter
@onready var journal_button = $JournalIconButton


func _ready():
	journal_button.hide()
	journal_button.pressed.connect(on_journal_button_pressed)


func set_day(day_number):
	day_label.text = "Day " + str(day_number)


func show_journal_button():
	journal_button.show()


func on_journal_button_pressed():
	journal_button_pressed.emit()
