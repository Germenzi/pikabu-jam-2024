extends Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = $"../Player".position
	$Vignette.position.x = get_target_position()[0] - $"../Player".position.x - 840
	$Vignette.position.y = get_target_position()[1] - $"../Player".position.y - 360

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = $"../Player".position
	$Vignette.position.x = get_target_position()[0] - $"../Player".position.x - 840
	$Vignette.position.y = get_target_position()[1] - $"../Player".position.y - 360
	
