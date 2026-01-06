extends CanvasLayer
signal start_game

@onready var game_timer = $GameTimer
@onready var time_label = $TimeLabel
@onready var leaderboard = preload("res://leaderboard.gd").new()

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	$NameInput.hide()
	$SubmitButton.hide()
	$StartButton.show()
	$LeaderboardButton.show()
	add_child(leaderboard)


# Called every frame. 'delta' is the elapsed time since the previous frame
func _process(_delta: float) -> void:
	if game_timer.time_left > 0:
		var current_second = ceil(game_timer.time_left)
		time_label.text = "Time: " + str(current_second)

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
