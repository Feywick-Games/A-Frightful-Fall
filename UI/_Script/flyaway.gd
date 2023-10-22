class_name FlyAway
extends Control

@onready
var action_button : Button = %ActionButton
@onready
var wish_button : Button = %WishButton
@onready
var end_turn : Button = %EndTurnButton

var _active_tile : int
var _start_tile : int
var _start_facing : Unit.Facing

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


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel") and GameState.active_unit_moved == true and not visible\
	and not GameState.active_unit.moving:
		EventBus.action_panel_toggled.emit(_active_tile)
		GameState.active_unit_moved = false
		var active_unit := GameState.active_unit
		var start_pos := Graph.get_tile_position(_start_tile)
		active_unit.global_position = Vector3(start_pos.x, active_unit.global_position.y, start_pos.z)
		active_unit.facing = _start_facing
		Graph.register_tile(active_unit, active_unit.tile_index)
		active_unit.tile_index = _start_tile
		EventBus.range_requested.emit(active_unit.tile_index, active_unit.stats, active_unit.is_ally)
		EventBus.action_panel_toggled.emit(_start_tile)
	elif Input.is_action_just_pressed("ui_cancel") and visible:
		EventBus.action_panel_toggled.emit(_active_tile)


func _on_target_position_reached() -> void:
	var active_unit := GameState.active_unit
	EventBus.range_requested.emit(active_unit.tile_index, active_unit.stats, active_unit.is_ally)
	active_unit.target_position_reached.disconnect(_on_target_position_reached)


func _on_action_button_pressed() -> void:
	EventBus.action_taken.emit()
	if action_button.text == "Attack":
		var active_unit = GameState.active_unit
		
		var target = Graph.get_tile_occupant(_active_tile)
		var direction = (target.global_position - active_unit.global_position).normalized()
		active_unit.attack(direction)
		EventBus.action_panel_toggled.emit(_active_tile)
		await get_tree().create_timer(active_unit.stats.damage_time_offset).timeout
		target.take_damage(active_unit.stats.damage, active_unit.stats.damage_type)
	else:
		var active_unit := GameState.active_unit
		_start_tile = active_unit.tile_index
		_start_facing = active_unit.facing
		GameState.active_unit_moved = true
		active_unit.move_to_tile(_active_tile)
		active_unit.target_position_reached.connect(_on_target_position_reached)
		EventBus.action_panel_toggled.emit(_active_tile)



func _on_end_turn_button_pressed() -> void:
	GameState.active_unit.end_turn()
	EventBus.action_taken.emit()
	EventBus.action_panel_toggled.emit(_active_tile)
