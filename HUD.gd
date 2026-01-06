extends CanvasLayer
signal start_game
signal restart_game

@onready var game_timer = $GameTimer
@onready var time_label = $TimeLabel
@onready var leaderboard = preload("res://leaderboard.gd").new()
@onready var heart1 = $Heart1
@onready var heart2 = $Heart2
@onready var heart3 = $Heart3
@onready var attack_label = $AttackLabel

var max_health = 3
var current_health = 3

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	$NameInput.hide()
	$SubmitButton.hide()
	$PauseButton.hide()
	$RestartButton.hide()
	$StartButton.show()
	$LeaderboardButton.show()
	add_child(leaderboard)
	update_health_display()


# Called every frame. 'delta' is the elapsed time since the previous frame
func _process(_delta: float) -> void:
	if game_timer.time_left > 0:
		var current_second = ceil(game_timer.time_left)
		time_label.text = "Time: " + str(current_second)
	
	# Position hearts above the player
	if get_parent().has_node("Player"):
		var player = get_parent().get_node("Player")
		var screen_pos = player.position
		var heart_y = screen_pos.y - 80  # 50 pixels above player
		var heart_spacing = 30
		var heart_offset_x = -25
		heart1.position = Vector2(screen_pos.x - heart_spacing + heart_offset_x, heart_y)
		heart2.position = Vector2(screen_pos.x + heart_offset_x, heart_y)
		heart3.position = Vector2(screen_pos.x + heart_spacing + heart_offset_x, heart_y)

# Display a message in the center of the screen for 2 seconds
func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

# Display the game over message and final score
func show_game_over():
	show_message("Game Over")
	$ScoreLabel.hide()
	show_message("Final score: %d" % [Score.score])
	await $MessageTimer.timeout
	# Show name input for leaderboard
	show_name_input()
	$PauseButton.hide()
	$RestartButton.hide()

# Show the name input UI
func show_name_input():
	$Message.text = "Enter your name:"
	$Message.show()
	$NameInput.show()
	$NameInput.text = ""
	$NameInput.grab_focus()
	$SubmitButton.show()

# Update the score display with current score
func update_score():
	$ScoreLabel.text = str(Score.score)

# Update the health display
func update_health_display():
	heart1.visible = current_health >= 1
	heart2.visible = current_health >= 2
	heart3.visible = current_health >= 3

# Update the attack status display
func update_attack_status(cooldown_time: float, is_active: bool):
	if is_active:
		attack_label.text = "ATTACKING!"
		attack_label.modulate = Color(1, 0.5, 0.5)
	elif cooldown_time > 0:
		attack_label.text = "Cooldown: %.1f" % cooldown_time
		attack_label.modulate = Color(0.5, 0.5, 0.5) 
	else:
		attack_label.text = "Attack Ready (Space)"
		attack_label.modulate = Color(1, 1, 1)

# Decrease health by 1
func decrease_health():
	current_health -= 1
	update_health_display()
	if current_health <= 0:
		get_parent().game_over()

# Reset health to max
func reset_health():
	current_health = max_health
	update_health_display()

# Start the game timer with a specified duration
func start_timer():
	game_timer.start(10.0)
	time_label.text = "Time: 10"

# Stop the game timer and clear the time display
func stop_timer():
	game_timer.stop()
	time_label.text = ""

# Handle StartButton pressed event to start a new game
func _on_start_button_pressed():
	$StartButton.hide()
	$LeaderboardButton.hide()
	$NameInput.hide()
	$SubmitButton.hide()
	$PauseButton.show()
	$RestartButton.show()
	start_game.emit()

# Handle LeaderboardButton pressed event to show leaderboard
func _on_leaderboard_button_pressed():
	get_tree().change_scene_to_file("res://leaderboard.tscn")

# Handle SubmitButton pressed event to save score and show start button
func _on_submit_button_pressed():
	var player_name = $NameInput.text.strip_edges()
	if player_name == "":
		player_name = "Anonymous"
	
	leaderboard.add_entry(player_name, Score.score)
	
	$NameInput.hide()
	$SubmitButton.hide()
	
	# Show "Devour all" message (no timer)
	$Message.text = "Devour all"
	$Message.show()
	# Show StartButton after a delay
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()
	$LeaderboardButton.show()

# Handle name input text submitted (Enter key)
func _on_name_input_text_submitted(_new_text: String) -> void:
	_on_submit_button_pressed()

# Handle MessageTimer timeout to hide the message
func _on_message_timer_timeout():
	$Message.hide()

# Handle GameTimer timeout to end the game
func _on_game_timer_timeout():
	print("Game timer has timed out!")
	stop_timer()
	# Emit a signal or call game_over on main
	get_parent().game_over()

# Handle PauseButton pressed
func _on_pause_button_pressed():
	get_tree().paused = !get_tree().paused
	if get_tree().paused:
		$PauseButton.text = "Resume"
	else:
		$PauseButton.text = "Pause"

# Handle RestartButton pressed
func _on_restart_button_pressed():
	restart_game.emit()
