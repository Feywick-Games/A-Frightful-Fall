class_name Enemy
extends Unit

func _ready() -> void:
	super._ready()
	self.is_ally = false


func _on_encounter_started(group : String):
	super._on_encounter_started(group)
	if is_in_group(group):
		Graph.register_tile(self, -1)
	print("enemy pos:", Graph.get_tile_position(tile_index))


func start_turn() -> void:
	super.start_turn()
	await EventBus.camera_destination_reached


func process_turn() -> void:
	pass
