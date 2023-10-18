extends Node

enum State {
	ROAM,
	BATTLE,
	IN_DIALOGUE
}

var state : State

func _ready() -> void:
	EventBus.encounter_started.connect(_on_encounter_started)
	EventBus.encounter_ended.connect(_on_encounter_ended)


func _on_encounter_started(_group : String) -> void:
	state = State.BATTLE


func _on_encounter_ended() -> void:
	state = State.BATTLE
