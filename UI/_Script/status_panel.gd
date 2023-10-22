class_name StatusPanel
extends PanelContainer

@onready
var health_bar = %HealthBar
@onready
var name_label = %NameLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.unit_highlighted.connect(_on_unit_highlighted)
	hide()


func _on_unit_highlighted(stats : StatBlock) -> void:
	if stats:
		show()
		name_label.text = stats.name
		health_bar.max_value = stats.health
		health_bar.value = stats.current_health
	else:
		hide()
