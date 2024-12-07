extends Node2D

signal player_ready

enum Levels {
	Level1
}

@export_category("player")
@export var player_x : int
@export var player_y : int

@export_category("level")
@export var level : PackedScene

@export_category("camera")
@export var camera_left_limit : int = 0
@export var camera_right_limit : int = 1000
@export var camera_top_limit : int = 0
@export var camera_bottom_limit : int = 720


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Camera2D.position.x = 0
	$Camera2D.position.y = 0
	$Camera2D.limit_left = camera_left_limit
	$Camera2D.limit_right = camera_right_limit
	$Camera2D.limit_top = camera_top_limit
	$Camera2D.limit_bottom = camera_bottom_limit
	
	add_child(level.instantiate())
	
	var player = preload(ScenesNamespace.PLAYER_FILEPATH)
	player = player.instantiate()
	player.position.x = player_x
	player.position.y = player_y
	add_child(player)
	$Camera2D.player = player
	player_ready.emit()
	
	if not GuiTransitions.in_transition():
		await(get_tree().create_timer(2).timeout)
		print("HIED")
		GuiTransitions.hide("LoadingLevel")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
