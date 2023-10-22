# aoe fairy
extends Enemy



func start_turn(participants : Array[Unit]) -> void:
	await super.start_turn(participants)
	
	if not charging:
		var lowest_score : int = 100
		
		var move_range := Graph.get_range_ids(tile_index, stats.movement, is_ally)
		var in_range := false
		var ideal_tile : int
		
		for id in move_range:
			var score : int = 0
			for participant in participants:
				if participant is Ally:
					var distance := len(Graph.get_path_ids(id, participant.tile_index, true))
					var attack_range := Graph.get_range_ids(id, stats.reach - 1, is_ally, true)
					var can_hit := false
					if participant.tile_index in attack_range:
						can_hit = true

					score += participant.stats.current_health + distance
					
					if score < lowest_score and (can_hit == true or in_range == false):
						ideal_tile = id
						lowest_score = score
						in_range = true

		if ideal_tile != tile_index:
			move_to_tile(ideal_tile)
			await target_position_reached
		if in_range:
			_animate("PreAttack", _facing)
			_animate("Charge",_facing, false, false, true)
			charging = true
		
		end_turn()
		
	else:
		var blast_range := Graph.get_range_ids(tile_index, stats.movement + stats.reach, is_ally, true)
		var damage_takers : Array[Unit] = []
		
		for participant in participants:
			if participant.tile_index in blast_range:
				if participant is Ally:
					damage_takers.append(participant)
		
		EventBus.camera_follow_requested.emit(self)
		attack(Vector3.ZERO)
		await get_tree().create_timer(stats.damage_time_offset).timeout
		
		for damage_taker in damage_takers:
			damage_taker.take_damage(stats.damage, stats.damage_type)

