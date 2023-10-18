class_name Unit
extends CharacterBody3D

@export_range(1,16)
var speed : float
@export
var movement : int
@export
var reach : int
var tile_index : int
var is_ally : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.encounter_started.connect(_on_encounter_started)


func _on_encounter_started(_group : String) -> void:
	tile_index = Graph.get_unoccupied_tile_index(global_position)


func start_turn() -> void:
	var rng : Array[int] = Graph.get_range_ids(tile_index, movement, is_ally)
