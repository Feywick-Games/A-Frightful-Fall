class_name Player
extends Ally



func _ready() -> void:
	EventBus.camera_follow_requested.emit(self)
	super._ready()
	await get_tree().create_timer(1).timeout 
	EventBus.encounter_started.emit("demo")


func _physics_process(delta: float) -> void:
	if GameState.state == GameState.State.ROAM:
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			_facing = _vec2_to_facing(input_dir)
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)		
		
		move_and_slide()
	super._physics_process(delta)
