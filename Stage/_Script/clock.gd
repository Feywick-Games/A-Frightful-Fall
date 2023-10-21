class_name Clock
extends Node

var _participants : Array[Unit]

func _ready() -> void:
	EventBus.encounter_started.connect(_on_encounter_started)
	EventBus.turn_ended.connect(_on_turn_ended)


func _on_encounter_started(group : String) -> void:
	var group_nodes := get_tree().get_nodes_in_group("ally") + get_tree().get_nodes_in_group(group) 
	for node in group_nodes as Array[Unit]:
		_participants.append(node)
	_participants.sort_custom(_has_highest_speed)
	_set_active_unit()


func _on_turn_ended() -> void:
	_set_active_unit()


func _set_active_unit() -> void:
	var active_unit : Unit = _participants.pop_front()
	active_unit.start_turn()
	_participants.append(active_unit)
	GameState.active_unit = active_unit
	if active_unit is Ally:
		EventBus.turn_started.emit(GameState.BattleSubState.PLAYER_TURN)
	elif active_unit is Enemy:
		EventBus.turn_started.emit(GameState.BattleSubState.ENEMY_TURN)
	else:
		printerr("non clarified unit turn in clock")




func _has_highest_speed(a : Unit, b : Unit) -> bool:
	if a.stats.speed > b.stats.speed:
		return true
	else:
		return false
