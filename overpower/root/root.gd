extends Node

@onready var world:World = $World

func _ready() -> void:
	ECS.world = world
	
func _process(dt: float) -> void:
	world.process(dt, "input")
	world.process(dt, "gameplay")

func _physics_process(dt: float) -> void:
	world.process(dt, "physics")
