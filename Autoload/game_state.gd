extends Node

enum State {
	ROAM,
	BATTLE,
	SCENE,
	DIALOGUE,
	MENU
}

enum BattleSubState {
	PLAYER_TURN,
	ENEMY_TURN,
	NPC_TURN
}

enum SceneSubState {
	DIALOGUE,
	VIEWING
}

var state : State
var sub_state : int
var active_unit : Unit
var active_unit_moved := false

func _ready() -> void:
	EventBus.encounter_started.connect(_on_encounter_started)
	EventBus.encounter_ended.connect(_on_encounter_ended)
	EventBus.turn_started.connect(_on_turn_started)


func _on_encounter_started(_group : String) -> void:
	state = State.BATTLE
	_on_turn_started(BattleSubState.PLAYER_TURN)


func _on_encounter_ended() -> void:
	state = State.BATTLE


func _on_turn_started(battle_state : BattleSubState) -> void:
	sub_state = battle_state
	active_unit_moved = false
