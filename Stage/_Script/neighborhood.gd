class_name Neighborhood
extends Node3D


func get_floor_bounding_boxes() -> Array[AABB]:
	var out : Array[AABB] = []
	
	for child in get_children() as Array[Node3D]:
		if child.is_in_group("floor"):
			var aabb : AABB = (child as MeshInstance3D).get_aabb()
			aabb.position = child.to_global(aabb.position)
			out.append(aabb)
	return out 


func get_props() -> Array[Prop]:
	var out : Array[Prop] = []
	
	for child in find_children("*", "Prop") as Array[Node]:
		out.append(child)
	
	return out
