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


func _on_turn_started(sub_state : GameState.BattleSubState) -> void:
	_active_unit = GameState.active_unit
	_selection_node.global_position = _active_unit.position
	EventBus.camera_follow_requested.emit(_selection_node)


func _on_range_requested(movement_ids : Array[int], range_ids : Array[int]) -> void:
	_mesh_dict.clear()
	_movement_range.clear()
	_action_range.clear()
	_empty_range.clear()
	var active_tile : int
	_movement_range = movement_ids
	
	for id in range_ids:
		if not id in _movement_range:
			if Graph.has_occupant(id):
				_action_range.append(id)
			else:
				_empty_range.append(id)
		elif Graph.get_tile_occupant(id) == GameState.active_unit:
			active_tile = id
	
	for id in movement_ids + range_ids:
		var mesh_instance := MeshInstance3D.new()
		if id == active_tile:
			mesh_instance.mesh = _move_select_mesh
		elif id in _movement_range:
			mesh_instance.mesh = _move_mesh
		elif id in _action_range:
			mesh_instance.mesh = _action_mesh
		elif id in _empty_range:
			mesh_instance.mesh = _empty_mesh
		
		_cur_tile_idx = active_tile
		add_child(mesh_instance)
		mesh_instance.global_position = Graph.get_tile_position(id) + Vector3(0,0.01,0)
		_mesh_dict[id] = mesh_instance



func _process(delta: float) -> void:
	if GameState.state == GameState.State.BATTLE:
		if GameState.sub_state == GameState.BattleSubState.PLAYER_TURN:
			var direction : Vector2
			if Input.is_action_just_pressed("move"):
				direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
			if direction:
				print(_cur_tile_idx)
				var nearest_tile = Graph.get_tile_id(
					_selection_node.global_position + Vector3(direction.x, 0, direction.y)
				)
				if nearest_tile in _movement_range + _action_range + _empty_range and nearest_tile != _cur_tile_idx:
					_selection_node.global_position = Graph.get_tile_position(nearest_tile)
					if nearest_tile in _movement_range:
						_mesh_dict[nearest_tile].mesh = _move_select_mesh
					elif nearest_tile in _action_range:
						_mesh_dict[nearest_tile].mesh = _action_select_mesh
					elif nearest_tile in _empty_range:
						_mesh_dict[nearest_tile].mesh = _empty_select_mesh
					
					if _cur_tile_idx in _movement_range:
						_mesh_dict[_cur_tile_idx].mesh = _move_mesh
					elif _cur_tile_idx in _action_range:
						_mesh_dict[_cur_tile_idx].mesh = _action_mesh
					elif _cur_tile_idx in _empty_range:
						_mesh_dict[_cur_tile_idx].mesh = _empty_mesh
					
					_cur_tile_idx = nearest_tile
			if Input.is_action_just_pressed("ui_accept"):
				var target = Graph.get_tile_occupant(_cur_tile_idx)
				if target:
					print(target.name)
				
			
		elif GameState.sub_state == GameState.BattleSubState.ENEMY_TURN:
			pass
