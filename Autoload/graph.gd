extends Node

var _graph : AStar3D = AStar3D.new()
var _unit_registry : Dictionary


func _ready() -> void:
	EventBus.encounter_started.connect(_on_encounter_started)
	EventBus.encounter_ended.connect(_on_encounter_ended)


func _on_encounter_started(group : String) -> void:
	var neighborhood : Neighborhood = get_tree().get_first_node_in_group(group + "_neighborhood")
	_add_neighborhood(neighborhood)


func _on_encounter_ended() -> void:
	_graph.clear()
	_unit_registry.clear()


func _add_neighborhood(neighborhood : Neighborhood) -> void:
	var floor_boxes : Array[AABB] = neighborhood.get_floor_bounding_boxes()
	var props : Array[Prop] = neighborhood.get_props()
	
	
	for box in floor_boxes:
		var point_map : Array[Array] = []
		var zi : int = 0
		for z in range(box.position.z, box.end.z + 1, 1):
			point_map.append([])
			var xi : int = 0
			for x in range(box.position.x, box.end.x + 1, 1): 
				point_map[zi].append(_graph.get_available_point_id())
				_graph.add_point(point_map[zi][xi], Vector3(x,0,z))
				
				var blocked := false
				var weight : float = 0.0
				for prop in props:
					if prop.rect.has_point(Vector2(x,z)):
						blocked = true
						break
				
				if blocked:
					_graph.set_point_disabled(point_map[zi][xi])
				else:
					if xi > 0:
						if point_map[zi][xi-1] != null:
							_graph.connect_points(point_map[zi][xi], point_map[zi][xi-1])
					if zi > 0:
						if point_map[zi-1][xi] != null:
							_graph.connect_points(point_map[zi][xi], point_map[zi-1][xi])
				xi += 1
			zi += 1


func get_unoccupied_tile_index(position : Vector3) -> int:
	# query the graph and check for occupants 
	var id = _graph.get_closest_point(position)
	assert(id != -1)
	return id


func register_tile(unit : Unit, old_index : int) -> void:
	_unit_registry[unit.tile_index] = unit
	if old_index != -1:
		_unit_registry.erase(old_index)


func get_tile_position(id : int) -> Vector3:
	return _graph.get_point_position(id)


func _toggle_tiles(is_ally : bool) -> void:
	for id in _unit_registry.keys():
		var unit : Unit = _unit_registry[id]
		if unit is Ally:
			_graph.set_point_disabled(id, !is_ally)
		if unit is Enemy:
			_graph.set_point_disabled(id, is_ally)


func get_range_ids(start_index : int, distance : int, is_ally : bool) -> Array[int]:
	_toggle_tiles(is_ally)
	var output : Array[int] = []
	var start_pos : Vector3 = _graph.get_point_position(start_index)
	print(start_pos)
	var zi : int = 0
	for z in range(start_pos.z - distance, start_pos.z + distance + 1):
		for x in range(start_pos.x - zi, start_pos.x + zi + 1):
			var point_id : int = _graph.get_closest_point(Vector3(x,0,z), true)
			
			if _graph.is_point_disabled(point_id):
				print("disabled")
			
			var point_dist : int = len(_graph.get_id_path(start_index, point_id)) - 1
			
			if point_dist <= distance and point_dist >= 0:
				output.append(point_id)
		if z < start_pos.z:
			zi += 1
		else:
			zi -= 1
		
	_toggle_tiles(!is_ally)
	return output


func _manhattan_dist(start:Vector3, end:Vector3) -> float:
	return abs(end.x - start.x) + abs(end.y - start.y)


#func _depth_search(source_id : int, depth : int, con_id : int = -1, output =[]) -> Array[int]:
#	if con_id == -1:
#		con_id = source_id
#
#	if depth > 0:
#		var connections : PackedInt64Array = _graph.get_point_connections(con_id)
#		var unchecked : Array[int] = []
#		for connection in connections:
#			if connection not in output and not _graph.is_point_disabled(connection):
#				var pos : Vector3 = _graph.get_point_position(connection)
#				var src_pos : Vector3 = _graph.get_point_position(source_id)
#				var weight : int = floori(_graph.get_point_weight_scale(connection))
#				var dist : int = abs(pos.x - src_pos.x) + abs(pos.y - src_pos.y) + weight
#				depth = depth - dist
#
#				output.append(connection)
#				unchecked.append(connection)
#				output = _depth_search(connection, depth, output)
#
#	return output
