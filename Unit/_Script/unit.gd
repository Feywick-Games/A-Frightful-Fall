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
	if GameState.state == GameState.State.ROAM or moving:
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
			velocity = Vector3.ZERO
			target_position_reached.emit()



func start_turn() -> void:
	var move_rng = Graph.get_range_ids(tile_index,stats.movement,true)
	var all_rng = Graph.get_range_ids(tile_index,stats.movement + stats.reach,true, true)
	EventBus.range_requested.emit(tile_index,stats,is_ally)

func _vec2_to_facing(dir : Vector2) -> Facing:
	if dir.x > 0:
		return Facing.RIGHT
	elif dir.x < 0:
		return Facing.LEFT
	elif dir.y < 0:
		return Facing.UP
	else:
		return Facing.DOWN


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

