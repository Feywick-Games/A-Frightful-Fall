class_name Ally
extends Unit


func _ready() -> void:
	super._ready()
	self.is_ally = true



func _process(delta: float) -> void:
	super._process(delta)
	if GameState.state == GameState.State.ROAM:
		if velocity.length() < 0.01:
			_animate("Idle", _facing)
		else:
			_animate("Move", _facing)
	


func _on_encounter_started(group : String):
	super._on_encounter_started(group)
	tile_index = Graph.get_unoccupied_tile_index(global_position)
	target_position = Graph.get_tile_position(tile_index)
	target_position.y = global_position.y
	moving = true
	Graph.register_tile(self, -1)
	target_position_reached.emit()
