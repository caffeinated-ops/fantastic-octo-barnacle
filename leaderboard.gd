extends Node

const LEADERBOARD_FILE = "user://leaderboard.json"

var leaderboard_data = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_leaderboard()

# Load leaderboard data from file
func load_leaderboard():
	if FileAccess.file_exists(LEADERBOARD_FILE):
		var file = FileAccess.open(LEADERBOARD_FILE, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()

			var json = JSON.new()
			var parse_result = json.parse(json_string)
			if parse_result == OK:
				var data = json.data
				if data is Array:
					leaderboard_data = []
					for item in data:
						if item is Dictionary and item.has("name") and item.has("score"):
							leaderboard_data.append(item)
						else:
							print("Invalid leaderboard entry: ", item)
				else:
					leaderboard_data = []
			else:
				print("Error parsing leaderboard JSON: ", json.get_error_message())
				leaderboard_data = []
		else:
			print("Error opening leaderboard file for reading")
			leaderboard_data = []
	else:
		leaderboard_data = []

# Save leaderboard data to file
func save_leaderboard():
	var file = FileAccess.open(LEADERBOARD_FILE, FileAccess.WRITE)
	var json_string = JSON.stringify(leaderboard_data)
	file.store_string(json_string)
	file.close()

# Add a new entry to the leaderboard
func add_entry(player_name: String, score: int):
	var current_time = Time.get_datetime_dict_from_system()
	var entry = {
		"name": player_name,
		"score": score,
		"date": "%04d-%02d-%02d" % [current_time.year, current_time.month, current_time.day],
		"time": "%02d:%02d:%02d" % [current_time.hour, current_time.minute, current_time.second]
	}

	leaderboard_data.append(entry)

	# Sort by score descending
	leaderboard_data.sort_custom(func(a, b): return a.score > b.score)

	# Keep only top 10 entries
	if leaderboard_data.size() > 10:
		leaderboard_data.resize(10)

	save_leaderboard()

# Get the leaderboard data (sorted)
func get_leaderboard():
	return leaderboard_data.duplicate()

# Get the player's rank for a given score
func get_rank(score: int) -> int:
	for i in range(leaderboard_data.size()):
		if score >= leaderboard_data[i].score:
			return i + 1
	return leaderboard_data.size() + 1
