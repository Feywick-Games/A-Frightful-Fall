class_name Foxfire
extends Ally

var move_started := false


func _process(delta: float) -> void:
	if moving and not move_started:
		_animate("Move", _facing)
		_animate("Hide", Facing.VOID, false, false, true)
		move_started = true
	else:
		if not moving:
			move_started = false
			
			
func start_turn(participants : Array[Unit]) -> void:
	super.start_turn(participants)
	if charging:
		var blast_range := Graph.get_range_ids(tile_index, stats.movement + stats.reach, is_ally, true)
		var damage_takers : Array[Unit] = []
		
		for participant in participants:
			if participant.tile_index in blast_range:
				if participant is Enemy:
					damage_takers.append(participant)
		
		attack(Vector3.ZERO)
		await get_tree().create_timer(stats.damage_time_offset).timeout
		
		for damage_taker in damage_takers:
			damage_taker.take_damage(stats.damage, stats.damage_type)
		
		charging = false

func _physics_process(delta: float) -> void:
	if moving and "Move" not in animation_player.current_animation:
		if global_position.distance_to(target_position) > .025:
			var new_v := (target_position - global_position).normalized() * speed
			velocity = new_v
			_facing = _vec2_to_facing(Vector2(velocity.x,velocity.z))
			move_and_slide()
		else:
			global_position = target_position
			_get_next_path_position()


func _on_target_position_reached() -> void:
	super._on_target_position_reached()
	_animate("Move", _facing, true)
	_animate("Idle", _facing, false, false, true)
	move_started = false

	
