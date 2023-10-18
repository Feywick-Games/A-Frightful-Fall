extends Camera3D

@export_range(1,16)
var follow_distance : float
@export_range(1,8)
var camera_offset : float
@export_range(0,1)
var follow_speed : float = 0.1

var _leader : Node3D
var _destination_reached := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.camera_follow_requested.connect(_on_camera_follow_requested)
	

func _on_camera_follow_requested(leader : Node3D) -> void:
	_leader = leader


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _leader:
		if _leader.global_position.distance_to(global_position) > follow_distance:
			if _destination_reached:
				_destination_reached = false
			
			var flat_leader_pos = Vector3(_leader.global_position.x, global_position.y, _leader.global_position.z)
			flat_leader_pos.z += camera_offset
			global_position = global_position.lerp(flat_leader_pos, follow_speed)
		elif not _destination_reached:
			_destination_reached = true
			EventBus.camera_destination_reached.emit()
