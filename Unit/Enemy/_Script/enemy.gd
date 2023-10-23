class_name Enemy
extends Unit



func _ready() -> void:
	super._ready()
	target_position = global_position + (Vector3(0,0,1) * 1)
	self.is_ally = false


func _on_encounter_started(group : String):
	super._on_encounter_started(group)
	if is_in_group(group):
		var index = Graph.get_unoccupied_tile_index(target_position)
		tile_index = index
		Graph.register_tile(self, tile_index, -1)
		move_to_tile(tile_index)


func start_turn(participants : Array[Unit]) -> void:
	super.start_turn(participants)
	await get_tree().create_timer(1).timeout
	EventBus.action_taken.emit()


func process_turn() -> void:
	pass
