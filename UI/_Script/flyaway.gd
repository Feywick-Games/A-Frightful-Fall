class_name FlyAway
extends Control

@onready
var action_button : Button = %ActionButton
@onready
var wish_button : Button = %WishButton
@onready
var end_turn : Button = %EndTurnButton

var _active_tile : int
var _has_moved : bool
var _start_tile : int

func _ready() -> void:
	EventBus.action_panel_toggled.connect(_on_action_panel_toggled)
	hide()


func _on_action_panel_toggled(tile : int) -> void:
	if visible:
		hide()
		return
	
	show()
	
	action_button.grab_focus()
	_active_tile = tile
	var target = Graph.get_tile_occupant(_active_tile)
	
	if target == GameState.active_unit:
		action_button.hide()
		wish_button.hide()
		end_turn.grab_focus()
		return
	elif target:
		wish_button.show()
		action_button.text = "Attack"
	else:
		wish_button.hide()
		action_button.text = "Move"
	action_button.show()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		EventBus.action_panel_toggled.emit(_active_tile)


func _on_active_unit_target_position_reached() -> void:
	_on_action_panel_toggled(_active_tile)


func _on_action_button_pressed() -> void:
	if action_button.text == "Attack":
		pass
	else:
		var active_unit := GameState.active_unit
		_start_tile = active_unit.tile_index
		_has_moved = true
		active_unit.target_position_reached.connect(_on_active_unit_target_position_reached)
		active_unit.move_to_tile(_active_tile)
	hide()



func _on_end_turn_button_pressed() -> void:
	GameState.active_unit.end_turn()
