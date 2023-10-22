extends Node

var _graph : AStar3D = AStar3D.new()
var _unit_registry : Dictionary
var aabb : AABB

func _ready() -> void:
	process_priority = -1
	EventBus.encounter_started.connect(_on_encounter_started)
	EventBus.encounter_ended.connect(_on_encounter_ended)
	EventBus.unit_died.connect(_on_unit_died)


func _on_unit_died(unit : Unit) -> void:
	_unit_registry.erase(unit.tile_index)


func _on_encounter_started(group : String) -> void:
	var neighborhood : Neighborhood = get_tree().get_first_node_in_group(group + "_neighborhood")
	_add_neighborhood(neighborhood)


func _on_encounter_ended() -> void:
	_graph.clear()
	_unit_registry.clear()


# could return special props/items in the future
func get_tile_occupant(tile_id : int) -> Unit:
	if tile_id in _unit_registry:
		return _unit_registry[tile_id]
	return null


func _add_neighborhood(neighborhood : Neighborhood) -> void:
	var floor_boxes : Array[AABB] = neighborhood.get_floor_bounding_boxes()
	var props : Array[Prop] = neighborhood.get_props()
	
	
	for box in floor_boxes:
		var point_map : Array[Array] = []
		var zi : int = 0
		aabb = aabb.merge(box)
		for z in range(box.position.z, box.end.z + 1, 1):
			point_map.append([])
			var xi : int = 0
			for x in range(box.position.x, box.end.x + 1, 1): 
				
				var blocked_up := false
				var blocked_left := false
				
				var blocked := false
				var weight : float = 1.0
				for prop in props:
				
					if prop.rect.has_point(Vector2(x,z)):
						if not prop.is_blockade:
							blocked = true
							weight = prop.weight
							break
					if prop.is_blockade:
						if prop.rect.has_point(Vector2(x,z - 1)):
							if prop.blocks_vertical:
								blocked_up = true
						if prop.rect.has_point(Vector2(x-1,z)):
							if not prop.blocks_vertical:
								blocked_left = true

				point_map[zi].append(_graph.get_available_point_id())
				_graph.add_point(point_map[zi][xi], Vector3(x,0,z), weight)
				
				if blocked:
					_graph.set_point_disabled(point_map[zi][xi])
				else:
					if xi > 0 and not blocked_left:
						if point_map[zi][xi-1] != null:
							_graph.connect_points(point_map[zi][xi], point_map[zi][xi-1])
					if zi > 0 and not blocked_up:
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

func get_tile_id(position : Vector3) -> int:
	_toggle_tiles(true)
	return _graph.get_closest_point(position)


func _toggle_tiles(all : bool, is_ally := true) -> void:
	for id in _unit_registry.keys():
		var unit : Unit = _unit_registry[id]
		if not all:
			if unit is Ally:
				_graph.set_point_disabled(id, !is_ally)
			if unit is Enemy:
				_graph.set_point_disabled(id, is_ally)
		else:
			_graph.set_point_disabled(id, false)


func get_range_ids(start_index : int, distance : int, is_ally : bool, toggle_all:= false) -> Array[int]:
	_toggle_tiles(toggle_all, is_ally)
	var output : Array[int] = []
	var start_pos : Vector3 = _graph.get_point_position(start_index)
	var zi : int = 0
	for z in range(start_pos.z - distance, start_pos.z + distance + 1):
		for x in range(start_pos.x - zi, start_pos.x + zi + 1):
			var point_id : int = _graph.get_closest_point(Vector3(x,0,z), true)
			
			if point_id in output:
				continue

			var point_dist : int = len(_graph.get_id_path(start_index, point_id)) - 1
			
			if point_dist <= distance and point_dist >= 0:
				output.append(point_id)
		if z < start_pos.z:
			zi += 1
		else:
			zi -= 1
		
	_toggle_tiles(true)
	return output


func get_stat_range(tile_index : int, stats : StatBlock, is_ally) -> Array[int]:
	var output : Array[int]
	var new_range : Array[int]
	var move_range := get_range_ids(tile_index, stats.movement, is_ally)
	for id in move_range:
		if not get_tile_occupant(id) or id == tile_index:
			new_range.append(id)
	
	move_range = new_range
	var range_ids : Array[int]
	
	for id in move_range:
		var action_ids := get_range_ids(id, stats.reach, is_ally, true)
		for action_id in action_ids:
			if action_id not in range_ids:
				range_ids.append(action_id)

	return move_range + range_ids


func has_occupant(id : int) -> bool:
	return id in _unit_registry
	
	
func get_closest_position(pos : Vector3) -> void:
	return _graph.get_point_position(_graph.get_closest_point(pos))


func get_path_positions3(from : int, to : int, is_ally : bool, toggle_all := false) -> PackedVector3Array:
	_toggle_tiles(toggle_all, is_ally)
	var path := _graph.get_point_path(from, to) 
	return path.slice(1)
	

func get_path_ids(from : int, to : int, is_ally : bool, toggle_all := false) -> PackedInt64Array:
	_toggle_tiles(toggle_all, is_ally)
	return _graph.get_id_path(from, to).slice(1)


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
