class_name Player

var health: int
var name: String
var player_node: CharacterBody2D

func _init(health_c: int = 100, name_c = "Noname", player_node_c: CharacterBody2D = null):
	self.health = health_c
	self.name = name_c
	self.player_node = player_node_c
	
	
func is_alive() -> bool:
	return self.health > 0
	
func get_name() -> String:
	return self.name
	
func get_node() -> Node2D:
	return self.player_node
