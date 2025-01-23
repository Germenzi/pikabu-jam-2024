extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate.a = 0
	await get_tree().create_timer(1).timeout

	var tween_in = get_tree().create_tween().set_parallel()
	tween_in.tween_property(self, "modulate:a", 1, 0.5)
	tween_in.tween_property(self, "position", Vector2(0, 25) + position, 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	await tween_in.finished
	
	await get_tree().create_timer(3).timeout
	
	var tween_out = get_tree().create_tween().set_parallel()
	tween_out.parallel().tween_property(self, "modulate:a", 0, 0.4)
	tween_out.parallel().tween_property(self, "position", position - Vector2(0, 25), 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	await tween_out.finished
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

	
