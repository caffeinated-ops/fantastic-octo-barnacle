extends Node

@export var mob_scene: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HUD.restart_game.connect(new_game)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func game_over():
	get_tree().paused = true
	$MobTimer.stop()
	$HUD.stop_timer()
	$HUD.show_game_over()


func new_game():
	get_tree().paused = false
	$MobTimer.stop()
	$HUD.stop_timer()
	Score.score = 0
	$HUD.update_score()
	$HUD.show_message("Get Ready")
	$Player.start($StartPosition.position)
	$StartTimer.start()
	get_tree().call_group("mobs", "queue_free")


func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's position to the random location.
	mob.position = mob_spawn_location.position

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Add some randomness to the direction.
	direction += randf_range(-0.1, 0.1)
	mob.add_to_group("mobs")
	#mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)

func _on_start_timer_timeout():
	$MobTimer.start()	
	$HUD.start_timer()
	
