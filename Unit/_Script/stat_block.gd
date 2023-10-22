class_name StatBlock
extends Resource
@export
var name : String
@export_range(1,5)
var health : int
@export_range(1,3)
var damage : int = 1
@export_range(1,16)
var speed : float
@export_range(1,8)
var movement : int
@export
var reach : int
@export
var damage_type : String
@export
var damage_time_offset : float
var current_health : int = health
