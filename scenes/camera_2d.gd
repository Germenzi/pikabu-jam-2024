extends Camera2D

# TODO: Опять же, абсолютный путь
@onready var vignette = $"../Player/Vignette"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = $"../Player".position
	
	# Если у камеры нет границ, то и без этого кода нормально
	# Но, так как при подходе границы камера как бы дальше них уходит, но нет
	vignette.position.x = get_target_position()[0] - $"../Player".position.x - 840
	vignette.position.y = get_target_position()[1] - $"../Player".position.y - 360

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = $"../Player".position
	
	# Если у камеры нет границ, то и без этого кода нормально
	# Но, так как при подходе границы камера как бы дальше них уходит, но нет
	vignette.position.x = get_target_position()[0] - $"../Player".position.x - 840
	vignette.position.y = get_target_position()[1] - $"../Player".position.y - 360
	
