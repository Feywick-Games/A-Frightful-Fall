class_name Ally
extends Unit

@export
var controlling := false
var target_position : Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	self.is_ally = true
#	for point in rng:
#		var pos = Graph.get_tile_position(point)
#		print(pos)
#		print(abs(pos.x - node_pos.x) + abs(pos.z - node_pos.z))
	await  get_tree().create_timer(2).timeout
	EventBus.encounter_started.emit("demo")


func _on_encounter_started(group : String):
	super._on_encounter_started(group)
	Graph.register_tile(self, -1)
