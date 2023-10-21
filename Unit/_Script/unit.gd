class_name Unit
extends CharacterBody3D

@export
var stats : StatBlock = StatBlock.new()

var tile_index : int
var is_ally : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.encounter_started.connect(_on_encounter_started)


func _on_encounter_started(_group : String) -> void:
	tile_index = Graph.get_unoccupied_tile_index(global_position)


func start_turn() -> void:
	var move_rng = Graph.get_range_ids(tile_index,stats.movement,true)
	var all_rng = Graph.get_range_ids(tile_index,stats.movement + stats.reach,true, true)
	EventBus.range_requested.emit(tile_index,stats,is_ally)
