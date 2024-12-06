extends CharacterBody2D

@export var SPEED = 450.0
@export var JUMP_VELOCITY = 400
var before_jump_y = 0

var player = Player.new(100, "Shut", self)

func _physics_process(delta: float):
	
	var jump = Input.is_action_pressed("Space")
	if jump:
		print("Before " + str(before_jump_y))
		before_jump_y = $AnimatedSprite2D.position.y
		$"AnimatedSprite2D".position.y = $AnimatedSprite2D.position.y  - 40
		print("After " + str(before_jump_y))
	else:
		$AnimatedSprite2D.position.y = before_jump_y
	
	$"Shadow".global_position = Vector2(position.x, position.y + 70)
	
	var direction:= Input.get_vector("A", "D", "W", "S")
	velocity = direction * SPEED
	move_and_slide()
