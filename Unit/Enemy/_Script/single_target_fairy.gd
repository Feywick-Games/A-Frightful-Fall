extends Enemy


func start_turn(participants : Array[Unit]) -> void:
	await super.start_turn(participants)
	
	var closest_unit : Unit
	var lowest_score : int = 100
	
	var move_range := Graph.get_range_ids(tile_index, stats.movement, is_ally)
	var attack_range : Array[int] = Graph.get_stat_range(tile_index, stats, is_ally)
	
	var range := move_range
		
	for id in attack_range:
		if id not in range:
			range.append(id)

	var in_range := false
	
	for participant in participants:
		if participant is Ally:
			if participant.tile_index in range:
				in_range = true
			var distance : int = len(Graph.get_path_positions3(tile_index, participant.tile_index, is_ally, true))
			var score : int = participant.stats.current_health + distance
			
			if score < lowest_score:
				closest_unit = participant
				lowest_score = score
	
	if in_range:
		var move_tile : int = get_furthest_in_range(closest_unit.tile_index)
		
		if move_tile != tile_index:
			move_to_tile(move_tile)
			await target_position_reached
		
		var direction : Vector3 = closest_unit.global_position - global_position
		attack(direction)
		await get_tree().create_timer(stats.damage_time_offset).timeout
		closest_unit.take_damage(stats.damage, stats.damage_type)
	else:
		var target_tile : int = get_closest_to_target(closest_unit.tile_index)

		EventBus.camera_follow_requested.emit(self)
		move_to_tile(target_tile)
		await target_position_reached
		end_turn()
