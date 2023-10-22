extends Button

@onready
var normal_style_box : StyleBoxEmpty = get_theme_stylebox("normal")


func _process(delta: float) -> void:
	if has_focus():
		normal_style_box.content_margin_left = 24
	else:
		normal_style_box.content_margin_left = 12
