class_name StatusPanel
extends PanelContainer

@onready
var health_bar : Range = %HealthBar
@onready
var name_label : Label = %NameLabel

var _stat_block : StatBlock
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.unit_highlighted.connect(_on_unit_highlighted)
	hide()


func _on_unit_highlighted(stats : StatBlock) -> void:
	_stat_block = stats
	if stats:
		show()
		name_label.text = stats.name
		health_bar.max_value = stats.health
		health_bar.value = stats.current_health
	else:
		hide()


func _process(_delta: float) -> void:
	if GameState.state == GameState.State.BATTLE:
		if _stat_block:
			if _stat_block.current_health != health_bar.value and _stat_block.name == name_label.text:
				health_bar.value = _stat_block.current_health 
	else:
		if visible:
			hide()
