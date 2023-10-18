class_name Unit
extends CharacterBody3D

var tile_index : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.encounter_started.connect(_on_encounter_started)

func _on_encounter_started(_group : String) -> void:
	tile_index = Graph.get_unoccupied_tile_index(global_position)
