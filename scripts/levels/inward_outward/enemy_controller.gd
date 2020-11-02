extends Node2D

# * Signals

# * Variables
var spawners: Array
var enemy_speed: float
const Enemy := preload("res://scenes/levels/inward_outward/arrow.tscn")
var timer

# * Functions


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	spawners.append($Spawner1)
	spawners.append($Spawner2)
	enemy_speed = 200.0
	timer = $Timer
	timer.start()


# Called to spawn an enemy with a certain speed
func spawn_enemy(spd = enemy_speed) -> void:
	var index = randi() % spawners.size()
	var spawner = spawners[index]
	var real_spd = spd
	if (index % 2) > 0:
		real_spd *= -1
	var enemy = Enemy.instance()
	add_child(enemy)
	enemy.hide()
	spawner.spawn(enemy, real_spd)
