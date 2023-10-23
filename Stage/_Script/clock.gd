class_name Clock
extends Node

var participants : Array[Unit]
var _positions_reached : int = 0

func _ready() -> void:
	process_priority = 1
	EventBus.encounter_started.connect(_on_encounter_started)
	EventBus.encounter_ended.connect(_on_encounter_ended)
	EventBus.turn_ended.connect(_on_turn_ended)
	EventBus.unit_died.connect(_on_unit_died)
	GameState.clock = self


func _on_encounter_ended() -> void:
	participants.clear()


func _on_unit_died(unit : Unit) -> void:
	participants.remove_at(participants.find(unit))
	var completed := true
	
	for participant in participants:
		if participant is Enemy:
			completed = false
			
	if completed:
		EventBus.encounter_ended.emit()


func _on_participant_target_position_reached() -> void:
	_positions_reached += 1
	if _positions_reached == len(participants):
		EventBus.all_positions_reached.emit()
		_positions_reached = 0


func _on_encounter_started(group : String) -> void:
	_positions_reached = 0
	var group_nodes := get_tree().get_nodes_in_group("ally") + get_tree().get_nodes_in_group(group) 
	for node in group_nodes as Array[Unit]:
		participants.append(node)
		node.target_position_reached.connect(_on_participant_target_position_reached)
	participants.sort_custom(_has_highest_speed)
	
	await EventBus.all_positions_reached
	_set_active_unit()


func _on_turn_ended() -> void:
	if participants.size() > 0:
		_set_active_unit()


func _set_active_unit() -> void:
	var active_unit : Unit = participants.pop_front()
	GameState.active_unit = active_unit
	if active_unit is Ally:
		EventBus.turn_started.emit(GameState.BattleSubState.PLAYER_TURN)
	elif active_unit is Enemy:
		EventBus.turn_started.emit(GameState.BattleSubState.ENEMY_TURN)
	else:
		printerr("non clarified unit turn in clock")
	active_unit.start_turn(participants)
	participants.append(active_unit)



func _has_highest_speed(a : Unit, b : Unit) -> bool:
	if a.stats.speed > b.stats.speed:
		return true
	else:
		return false
