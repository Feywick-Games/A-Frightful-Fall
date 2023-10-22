class_name Prop
extends Node3D

@export
var _size : Vector2
@export
var weight : float = INF
@export
var passable := false
@export
var is_blockade := false
@export
var blocks_vertical := false

var rect : Rect2:
	get:
		var out := Rect2()
		out.position = Vector2(global_position.x,global_position.z) - (_size / 2.0)
		out.size = _size
		return out

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if rect.size == Vector2.ZERO:
		printerr("rect not set for prop named " + name)
