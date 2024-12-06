extends CharacterBody2D

@export var SPEED = 300.0

func _physics_process(delta: float):
	var direction:= Input.get_vector("A", "D", "W", "S")
	velocity = direction * SPEED
	print(velocity)
	move_and_slide()
