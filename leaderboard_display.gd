extends Control

var font = load("res://fonts/Xolonium-Regular.ttf")

@onready var entries_container = $EntriesContainer
@onready var leaderboard_manager = preload("res://leaderboard.gd").new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(leaderboard_manager)
	display_leaderboard()

# Display the leaderboard entries
func display_leaderboard():
	# Clear existing entries
	for child in entries_container.get_children():
		child.queue_free()

	var data = leaderboard_manager.get_leaderboard()

	if data.size() == 0:
		var no_entries_label = Label.new()
		no_entries_label.text = "No entries yet!"
		no_entries_label.add_theme_font_override("font", font)
		no_entries_label.add_theme_font_size_override("font_size", 32)
		no_entries_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		entries_container.add_child(no_entries_label)
		return

	# Display top 10 entries
	for i in range(min(data.size(), 10)):
		var entry = data[i]
		var entry_label = Label.new()
		var date_str = entry.get("date", "")
		var time_str = entry.get("time", "")
		entry_label.text = "%d. %s - %d (%s %s)" % [i + 1, entry.name, entry.score, date_str, time_str]
		entry_label.add_theme_font_override("font", font)
		entry_label.add_theme_font_size_override("font_size", 24)
		entry_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		entries_container.add_child(entry_label)

# Handle back button pressed
func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://main.tscn")
