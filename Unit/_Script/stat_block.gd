class_name StatBlock
extends Resource
@export
var name : String
@export_range(1,4)
var health : int
@export
var damage : int = 1
@export_range(1,16)
var speed : float
@export_range(1,8)
var movement : int
@export
var reach : int
@export
var current_health : int = health
