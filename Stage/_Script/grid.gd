class_name Grid
extends Node3D

@export
var _tile_mesh : Mesh
var _mesh_list : Array[MeshInstance3D]


func _ready() -> void:
	EventBus.range_requested.connect(_on_range_requested)


func _on_range_requested(point_ids : Array[int]) -> void:
	for id in point_ids:
		var mesh_instance := MeshInstance3D.new()
		mesh_instance.mesh = _tile_mesh
		add_child(mesh_instance)
		mesh_instance.global_position = Graph.get_tile_position(id) + Vector3(0,0.01,0)
		_mesh_list.append(mesh_instance)
