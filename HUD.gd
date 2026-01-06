extends CanvasLayer
signal start_game

@onready var game_timer = $GameTimer
@onready var time_label = $TimeLabel

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	pass


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
	# Show "Devour all" message (no timer)
	$Message.text = "Devour all"
	$Message.show()
	# Show StartButton after a delay
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()

# Update the score display with current score
func update_score():
	$ScoreLabel.text = str(Score.score)

# Start the game timer with a specified duration
func start_timer():
	game_timer.start(5.0)
	time_label.text = "Time: 5"

# Stop the game timer and clear the time display
func stop_timer():
	game_timer.stop()
	time_label.text = ""

# Handle StartButton pressed event to start a new game
func _on_start_button_pressed():
	$StartButton.hide()
	start_game.emit()

# Handle MessageTimer timeout to hide the message
func _on_message_timer_timeout():
	$Message.hide()

# Handle GameTimer timeout to end the game
func _on_game_timer_timeout():
	print("Game timer has timed out!")
	stop_timer()
	# Emit a signal or call game_over on main
	get_parent().game_over()
