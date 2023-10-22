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

var _mesh_dict : Dictionary
var _target : Unit
var _cur_tile_idx : int = -1
var _active_unit : Unit
var _selection_node : Node3D
var _movement_range : Array[int]
var _action_range : Array[int]
var _empty_range : Array[int]

func _ready() -> void:
	EventBus.range_requested.connect(_on_range_requested)
	EventBus.turn_started.connect(_on_turn_started)
	_selection_node = Node3D.new()
	add_child(_selection_node)


func _on_turn_started(_sub_state : GameState.BattleSubState) -> void:
	_active_unit = GameState.active_unit
	EventBus.camera_follow_requested.emit(_selection_node)


func _on_range_requested(tile_index : int, stats : StatBlock, is_ally : bool) -> void:
	_mesh_dict.clear()
	_movement_range.clear()
	_action_range.clear()
	_empty_range.clear()
	_movement_range = Graph.get_range_ids(tile_index,stats.movement, is_ally)
	var range_ids := Graph.get_range_ids(tile_index, stats.movement + stats.reach, is_ally, true) 
	
	for id in range_ids:
		if not id in _movement_range:
			if Graph.has_occupant(id):
				_action_range.append(id)
			else:
				_empty_range.append(id)
	
	for id in _movement_range + _action_range + _empty_range:
		var mesh_instance := MeshInstance3D.new()
		if id in _movement_range:
			mesh_instance.mesh = _move_mesh
		elif id in _action_range:
			mesh_instance.mesh = _action_mesh
		elif id in _empty_range:
			mesh_instance.mesh = _empty_mesh
		
		add_child(mesh_instance)
		mesh_instance.global_position = Graph.get_tile_position(id) + Vector3(0,0.02,0)
		_mesh_dict[id] = mesh_instance
		
	_highlight_tile(tile_index)


func _highlight_tile(tile : int) -> void:
	if tile in _movement_range + _action_range + _empty_range:
		_selection_node.global_position = Graph.get_tile_position(tile)
		if tile in _movement_range:
			_mesh_dict[tile].mesh = _move_select_mesh
		elif tile in _action_range:
			_mesh_dict[tile].mesh = _action_select_mesh
		elif tile in _empty_range:
			_mesh_dict[tile].mesh = _empty_select_mesh
		
		if _cur_tile_idx != -1:
			if _cur_tile_idx in _movement_range:
				_mesh_dict[_cur_tile_idx].mesh = _move_mesh
			elif _cur_tile_idx in _action_range:
				_mesh_dict[_cur_tile_idx].mesh = _action_mesh
			elif _cur_tile_idx in _empty_range:
				_mesh_dict[_cur_tile_idx].mesh = _empty_mesh
		
		_cur_tile_idx = tile
		
	var target = Graph.get_tile_occupant(_cur_tile_idx)
	if target != _target:
		_target = target
		if _target:
			EventBus.unit_highlighted.emit(_target.stats)
		else:
			EventBus.unit_highlighted.emit(null)


func _process(_delta: float) -> void:
	if GameState.state == GameState.State.BATTLE:
		if GameState.sub_state == GameState.BattleSubState.PLAYER_TURN:
			var direction : Vector2
			if Input.is_action_just_pressed("move"):
				direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
			if direction:
				var nearest_tile = Graph.get_tile_id(_selection_node.global_position + Vector3(direction.x, 0, direction.y))
				_highlight_tile(nearest_tile)
				
			if _target:
				if Input.is_action_just_pressed("ui_accept"):
					print(_target.name)
					
			
		elif GameState.sub_state == GameState.BattleSubState.ENEMY_TURN:
			pass
