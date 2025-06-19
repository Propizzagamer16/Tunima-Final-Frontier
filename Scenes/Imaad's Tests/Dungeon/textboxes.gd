extends CanvasLayer

const CHAR_READ_RATE = 0.07
const DIALOGUE_LINES := [
	"First line of dialogue.",
	"Second line appears after pressing R.",
	"Third line here.",
	"And that's the end!"
]

@onready var textbox_container = $TextContainer
@onready var start_symbol = $TextContainer/MarginContainer/HBoxContainer/Start
@onready var end_symbol = $TextContainer/MarginContainer/HBoxContainer/End
@onready var label = $TextContainer/MarginContainer/HBoxContainer/Label
@onready var type_sfx: AudioStreamPlayer2D = $TypeSFX

var current_line_index := 0
var dialogue_active := false
var typing := false

func _ready():
	hide_textbox()
	dialogue_active = true
	await show_next_line()

func hide_textbox():
	start_symbol.text = ""
	end_symbol.text = ""
	label.text = ""
	textbox_container.hide()

func show_textbox():
	start_symbol.text = "*"
	textbox_container.show()

func _process(delta):
	if Input.is_action_just_pressed("next_text"):
		print("R (next_text) was pressed")

	if dialogue_active and not typing and Input.is_action_just_pressed("next_text"):
		current_line_index += 1
		if current_line_index < DIALOGUE_LINES.size():
			await show_next_line()
		else:
			dialogue_active = false
			hide_textbox()

func show_next_line() -> void:
	if not textbox_container.visible:
		show_textbox()

	label.text = ""
	end_symbol.text = ""
	typing = true
	await type_text(DIALOGUE_LINES[current_line_index])
	typing = false
	end_symbol.text = "v"

func type_text(text: String) -> void:
	var output := ""
	for i in text.length():
		output += text[i]
		label.text = output

		if text[i] != " ":
			type_sfx.stop()
			type_sfx.pitch_scale = randf_range(0.95, 1.05)
			type_sfx.play()

		await get_tree().create_timer(CHAR_READ_RATE).timeout
