extends Node

@export var mob_scene: PackedScene

var spawn_wave = 1
var spawn_counter = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HUD.start_game.connect(new_game)
	$HUD.restart_game.connect(func(): new_game(true))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func game_over():
	$MobTimer.stop()
	$HUD.stop_timer()
	$Player.set_process(false)
	$HUD/Message.hide()
	$HUD/AttackLabel.hide()
	get_tree().call_group("mobs", "queue_free")
	$HUD.show_game_over()


func new_game(is_restart: bool = false):
	get_tree().paused = false 
	$HUD.reset_pause_button()
	$MobTimer.stop()
	$HUD.stop_timer()
	Score.score = 0
	$HUD.update_score()
	$HUD.reset_health()
	$HUD.update_attack_status(0.0, false)
	if is_restart:
		$HUD.reset_ui(true)
	else:
		$HUD/RestartButton.hide()
		$HUD/PauseButton.hide()
		$HUD/StartButton.hide()
		$HUD/LeaderboardButton.hide()
		$HUD/NameInput.hide()
		$HUD/SubmitButton.hide()
	$HUD.show_message("Get Ready")
	$HUD/LeaderboardButton.hide()
	$Player.start($StartPosition.position + Vector2(0, 40))
	$Player.set_process(true)
	$StartTimer.start()
	get_tree().call_group("mobs", "queue_free")
	spawn_wave = 1
	spawn_counter = 0


func _on_mob_timer_timeout():
	spawn_counter += 1
	if spawn_counter % 10 == 0:
		spawn_wave += 1
	
	for i in range(spawn_wave):
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
	$HUD/PauseButton.show()
	$HUD.set_restart_button_style()
	$HUD/RestartButton.show()
	$HUD/StartButton.hide()
	$HUD/AttackLabel.show()
	$HUD/LeaderboardButton.hide()
	
