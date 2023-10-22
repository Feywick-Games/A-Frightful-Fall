class_name Foxfire
extends Ally

var move_started := false


func _on_target_position_reached() -> void:
	super._on_target_position_reached()
	_animate("Move", _facing, true)
	_animate("Idle", _facing, false, false, true)
	move_started = false
	
	
