class_name Foxfire
extends Enemy

var move_started := false

func _animate(anim : String, facing : Unit.Facing, reverse := false) -> void:
	if anim == "Move" and not move_started:
		move_started = true
		super._animate(anim, facing)
		return
	elif anim == "Move" and move_started and animation_player.is_playing() == false:
		super._animate("Hide", Unit.Facing.VOID)
		return
	elif anim == "Move" and reverse:
		super._animate("Move", _facing, reverse)
	
	if not "Move" in animation_player.current_animation and not move_started:
		super._animate(anim, facing)


func _physics_process(delta: float) -> void:
	if moving and not move_started:
		_animate("Move", _facing)
		velocity = Vector3.ONE
	elif moving and not "Move" in animation_player.current_animation:
		if global_position.distance_to(target_position) > .025:
			var new_v := (target_position - global_position).normalized() * speed
			velocity = new_v
			_facing = _vec2_to_facing(Vector2(velocity.x,velocity.z))
			move_and_slide()
		else:
			global_position = target_position
			velocity = Vector3.ZERO
			target_position_reached.emit()



func _on_target_position_reached() -> void:
	super._on_target_position_reached()
	_animate("Move", _facing, true)
	move_started = false

