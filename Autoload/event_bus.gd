extends Node

signal encounter_started(group : String)
signal encounter_ended()
signal range_requested(tile_index : int, stats : StatBlock, is_ally : bool)
signal turn_started(battle_state : GameState.BattleSubState)
signal turn_ended()
signal camera_follow_requested(leader : Node3D)
signal camera_destination_reached()
signal unit_highlighted(stat_block : StatBlock)
signal action_panel_toggled(active_tile : int)
signal all_positions_reached()
signal unit_died(unit : Unit)
signal action_taken()
