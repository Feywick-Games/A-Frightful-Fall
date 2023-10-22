class_name Grid
extends Node3D

@export
var _move_mesh : Mesh
@export
var _action_mesh : Mesh
@export
var _empty_mesh : Mesh
@export
var _move_select_mesh : Mesh
@export
var _action_select_mesh : Mesh
@export
var _empty_select_mesh : Mesh
@export
var _oob_mesh : Mesh


var _mesh_dict : Dictionary
var _target : Unit
var _cur_tile_idx : int = -1
var _active_unit : Unit
var _selection_node : Node3D
var _movement_range : Array[int]
var _action_range : Array[int]
var _empty_range : Array[int]
var _out_of_bounds : bool

var _in_selection : bool = false


func _ready() -> void:
	EventBus.range_requested.connect(_on_range_requested)
	EventBus.turn_started.connect(_on_turn_started)
	EventBus.encounter_started.connect(_on_encounter_started)
	EventBus.action_panel_toggled.connect(_on_action_panel_toggled)
	EventBus.action_taken.connect(_on_action_taken)
	EventBus.encounter_ended.connect(_on_encounter_ended)
	_selection_node = Node3D.new()
	add_child(_selection_node)


func _on_encounter_ended() -> void:
	_empty_grid()
	for mesh_i in _mesh_dict.values() as Array[MeshInstance3D]:
		mesh_i.queue_free()
	_mesh_dict.clear()
	_cur_tile_idx = -1


func _on_action_panel_toggled(tile : int) -> void:
	_in_selection = !_in_selection


func _on_encounter_started(group : String) -> void:
	var aabb = Graph.aabb
	for z in range(Graph.aabb.position.z, Graph.aabb.end.z + 1):
		for x in range(Graph.aabb.position.x, Graph.aabb.end.x + 1):
			var mesh_instance := MeshInstance3D.new()
			add_child(mesh_instance)
			var id = Graph.get_tile_id(Vector3(x,0,z))
			mesh_instance.global_position = Graph.get_tile_position(id) + Vector3(0,0.02,0)
			_mesh_dict[id] = mesh_instance


func _on_turn_started(_sub_state : GameState.BattleSubState) -> void:
	_active_unit = GameState.active_unit
	EventBus.camera_follow_requested.emit(_selection_node)
	_cur_tile_idx = -1


func _on_range_requested(tile_index : int, stats : StatBlock, is_ally : bool) -> void:
	_cur_tile_idx = -1
	_movement_range.clear()
	_action_range.clear()
	_empty_range.clear()
	if not GameState.active_unit_moved:
		_movement_range = Graph.get_range_ids(tile_index,stats.movement, is_ally)
	else:
		_movement_range = [tile_index]
	var range_ids : Array[int]


	var new_range : Array[int]
	for id in _movement_range:
		if not Graph.get_tile_occupant(id) or id == tile_index:
			new_range.append(id)
	
	_movement_range = new_range

	for id in _movement_range:
		var action_ids := Graph.get_range_ids(id, stats.reach, is_ally, true)
		for action_id in action_ids:
			if action_id not in range_ids:
				range_ids.append(action_id)

	
	
	for id in range_ids:
		if not id in _movement_range:
			var occupant = Graph.get_tile_occupant(id)
			if occupant and occupant.is_ally != is_ally:
				_action_range.append(id)
			else:
				_empty_range.append(id)
	
	for id in _movement_range + _action_range + _empty_range:
		
		if id in _movement_range:
			_mesh_dict[id].mesh = _move_mesh
		elif id in _action_range:
			_mesh_dict[id].mesh = _action_mesh
		elif id in _empty_range:
			_mesh_dict[id].mesh = _empty_mesh
		

		
	_highlight_tile(tile_index)


func _empty_grid() -> void:
	for id in _mesh_dict:
		_mesh_dict[id].mesh = null
	_movement_range.clear()
	_action_range.clear()
	_empty_range.clear()


func _highlight_tile(tile : int) -> void:

	_selection_node.global_position = Graph.get_tile_position(tile)
	if tile in _movement_range:
		_mesh_dict[tile].mesh = _move_select_mesh
	elif tile in _action_range:
		_mesh_dict[tile].mesh = _action_select_mesh
	elif tile in _empty_range:
		_mesh_dict[tile].mesh = _empty_select_mesh
	else:
		_mesh_dict[tile].mesh = _oob_mesh
	
	if _cur_tile_idx != -1:
		if _cur_tile_idx in _movement_range:
			_mesh_dict[_cur_tile_idx].mesh = _move_mesh
		elif _cur_tile_idx in _action_range:
			_mesh_dict[_cur_tile_idx].mesh = _action_mesh
		elif _cur_tile_idx in _empty_range:
			_mesh_dict[_cur_tile_idx].mesh = _empty_mesh
		else:
			_mesh_dict[_cur_tile_idx].mesh = null
	
	_cur_tile_idx = tile
	
	var target = Graph.get_tile_occupant(_cur_tile_idx)
	if target != _target:
		_target = target
		if _target:
			EventBus.unit_highlighted.emit(_target.stats)
		else:
			EventBus.unit_highlighted.emit(null)


func _on_action_taken() -> void:
	_empty_grid()


func _process(_delta: float) -> void:
	if GameState.state == GameState.State.BATTLE:
		if GameState.sub_state == GameState.BattleSubState.PLAYER_TURN and not _in_selection:
			var direction : Vector2
			if Input.is_action_just_pressed("move"):
				direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
			if direction:
				var nearest_tile = Graph.get_tile_id(_selection_node.global_position + Vector3(direction.x, 0, direction.y))
				_highlight_tile(nearest_tile)
				
			if Input.is_action_just_pressed("ui_accept") and _cur_tile_idx in _movement_range + _action_range:
				EventBus.action_panel_toggled.emit(_cur_tile_idx)
					
			
		elif GameState.sub_state == GameState.BattleSubState.ENEMY_TURN:
			pass
