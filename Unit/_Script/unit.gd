class_name Unit
extends CharacterBody3D

signal target_position_reached()

@export_range(0.0,3.0)
var speed := 2.0

@export
var stats : StatBlock = StatBlock.new()
@export
var animlib_name : String
@export
var transition_unit : PackedScene
@export
var no_attack_direction : bool
var transitioning := false

var target_position : Vector3
var moving := false
var died := false

var _path : PackedVector3Array

enum Facing {
	VOID,
	DOWN,
	UP,
	LEFT,
	RIGHT
}
var _facing : Facing = Facing.DOWN

var tile_index : int = -1
var is_ally : bool

@onready
var animation_player : AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.encounter_started.connect(_on_encounter_started)
	target_position_reached.connect(_on_target_position_reached)
	if not transitioning:
		stats.current_health = stats.health


func get_furthest_in_range(target_tile : int) -> int:
	var valid_range := Graph.get_range_ids(target_tile, stats.reach, is_ally, true)
	var attack_range := Graph.get_range_ids(target_tile, stats.reach + stats.movement, is_ally, true)
	var start_position := Graph.get_tile_position(tile_index)
	var ideal_id : int = -1
	var furthest_distance : int = 0
	var shortest_move : int = INF
	var target_position := Graph.get_tile_position(target_tile)
	
	for id in valid_range:
		if valid_range in attack_range:
			var pos := Graph.get_tile_position(id)
			if pos.distance_to(target_position) >= furthest_distance:
				if pos.distance_to(start_position) < shortest_move:
					ideal_id = id
	return ideal_id


func _on_encounter_started(_group : String) -> void:
	pass


func _on_target_position_reached() -> void:
	pass


func _process(delta: float) -> void:
	if moving:
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


func take_damage(damage : int, type : String) -> void:
	stats.current_health -= 1
	
	if stats.current_health == 0:
		_animate("Death", Facing.VOID)
		await animation_player.animation_finished
		EventBus.unit_died.emit(self)
		queue_free()
	else:
		_animate(type + "DamageTaken", Facing.VOID, false, true)
		_animate("Idle", _facing, false, false, true)


func start_turn() -> void:
	EventBus.range_requested.emit(tile_index,stats,is_ally)


func end_turn() -> void:
	EventBus.turn_ended.emit()


func _transition() -> void:
	pass


func _vec2_to_facing(dir : Vector2) -> Facing:
	if dir.x > 0:
		return Facing.RIGHT
	elif dir.x < 0:
		return Facing.LEFT
	elif dir.y < 0:
		return Facing.UP
	else:
		return Facing.DOWN



func attack(direction : Vector3) -> void:
	_facing = _vec2_to_facing(Vector2(direction.x,direction.z))
	_animate("Attack", _facing)
	_animate("Idle", _facing, false, false, true)
	if not no_attack_direction:
		var particles : CPUParticles3D = $CPUParticles3D
		particles.direction = direction
		particles.lifetime = direction.length() / 4.0

func move_to_tile(tile_id : int) -> void:
	_path = Graph.get_path_positions3(tile_index, tile_id)
	_get_next_path_position()


func _get_next_path_position() -> void:
	if len(_path) == 0:
		var old_id = tile_index
		tile_index = Graph.get_tile_id(target_position)
		if old_id != tile_index:
			Graph.register_tile(self, old_id)
		moving = false
		velocity = Vector3.ZERO
		_animate("Idle", _facing)
		target_position_reached.emit()
		return
	
	target_position = Vector3(_path[0].x, global_position.y, _path[0].z)
	moving = true
	_path.remove_at(0)


func _animate(anim : String, dir : Facing, reverse := false, no_lib := false, queue := false) -> void:
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
	
	var animation : String =  anim + anim_dir
	
	if not no_lib:
		animation = animlib_name + "/" + animation
	else:
		animation = "General" + "/" + animation
	
	if not anim + anim_dir == animation_player.current_animation:
		if not reverse:
			if not queue:
				animation_player.play(animation)
			else:
				animation_player.queue(animation)
		else:
			animation_player.play_backwards(animation)

