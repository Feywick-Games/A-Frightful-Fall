class_name Ally
extends Unit

@export
var mission_complete_dialogue : String


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
	var index : int = Graph.get_unoccupied_tile_index(global_position)
	tile_index = index
	Graph.register_tile(self, tile_index, -1)
	move_to_tile(tile_index)
