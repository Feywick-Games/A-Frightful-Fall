class_name Ally
extends Unit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	self.is_ally = true
#	for point in rng:
#		var pos = Graph.get_tile_position(point)
#		print(pos)
#		print(abs(pos.x - node_pos.x) + abs(pos.z - node_pos.z))


func _on_encounter_started(group : String):
	super._on_encounter_started(group)
	tile_index = Graph.get_unoccupied_tile_index(global_position)
	target_position = Graph.get_tile_position(tile_index)
	target_position.y = global_position.y
	moving = true
	Graph.register_tile(self, -1)
	target_position_reached.emit()
