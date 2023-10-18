class_name Enemy
extends Unit


func _on_encounter_started(group : String):
	super._on_encounter_started(group)
	if is_in_group(group):
		Graph.register_tile(self, -1)
	print("enemy pos:", Graph.get_tile_position(tile_index))
