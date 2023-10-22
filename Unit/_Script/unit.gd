class_name Unit
extends CharacterBody3D

signal target_position_reached()

@export_range(0.0,3.0)
var speed := 2.0

@export
var stats : StatBlock = StatBlock.new()
@export
var animlib_name : String

var target_position : Vector3
var moving := false

var _path : PackedVector3Array

enum Facing {
	VOID,
	DOWN,
	UP,
	LEFT,
	RIGHT
}
var _facing : Facing = Facing.DOWN

var tile_index : int
var is_ally : bool

@onready
var animation_player : AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.encounter_started.connect(_on_encounter_started)
	target_position_reached.connect(_on_target_position_reached)


func _on_encounter_started(_group : String) -> void:
	pass


func _on_target_position_reached() -> void:
	pass


func _process(delta: float) -> void:
	if velocity.length() < 0.01:
		_animate("Idle", _facing)
		moving = false
	else:
		_animate("Move", _facing)


func _physics_process(delta: float) -> void:
	if moving:
		if global_position.distance_to(target_position) > .025:
			var new_v := (target_position - global_position).normalized() * speed
			velocity = new_v
			_facing = _vec2_to_facing(Vector2(velocity.x,velocity.z))
			move_and_slide()
		else:
			global_position = target_position
			_get_next_path_position()



func start_turn() -> void:
	var move_rng = Graph.get_range_ids(tile_index,stats.movement,true)
	var all_rng = Graph.get_range_ids(tile_index,stats.movement + stats.reach,true, true)
	EventBus.range_requested.emit(tile_index,stats,is_ally)


func end_turn() -> void:
	EventBus.turn_ended.emit()


func _vec2_to_facing(dir : Vector2) -> Facing:
	if dir.x > 0:
		return Facing.RIGHT
	elif dir.x < 0:
		return Facing.LEFT
	elif dir.y < 0:
		return Facing.UP
	else:
		return Facing.DOWN


func move_to_tile(tile_id : int) -> void:
	_path = Graph.get_path_positions3(tile_index, tile_id)
	_get_next_path_position()


func _get_next_path_position() -> void:
	if len(_path) == 0:
		var old_id = tile_index
		tile_index = Graph.get_tile_id(target_position)
		Graph.register_tile(self, old_id)
		moving = false
		velocity = Vector3.ZERO
		target_position_reached.emit()
		return
	
	target_position = Vector3(_path[0].x, global_position.y, _path[0].z)
	moving = true
	_path.remove_at(0)


func _animate(anim : String, dir : Facing, reverse := false) -> void:
	var anim_dir = ""
	
	if not dir == Facing.VOID:
		if dir == Facing.LEFT:
			anim_dir = "Left"
		elif dir == Facing.RIGHT:
			anim_dir = "Right"
		elif dir == Facing.UP:
			anim_dir = "Up"
		elif dir == Facing.DOWN:
			anim_dir = "Down"
	
	var reverse_scale := -1 if reverse else 1 
	
	if not anim + anim_dir == animation_player.current_animation:
		if not reverse:
			animation_player.play(animlib_name + "/" + anim + anim_dir)
		else:
			animation_player.play_backwards(animlib_name + "/" + anim + anim_dir)

