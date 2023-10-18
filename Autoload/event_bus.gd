extends Node

signal encounter_started(group : String)
signal encounter_ended()
signal range_requested(move_ids : Array[int], action_ids : Array[int])
signal turn_started(battle_state : GameState.BattleSubState)
signal turn_ended()
signal camera_follow_requested(leader : Node3D)
signal camera_destination_reached()
