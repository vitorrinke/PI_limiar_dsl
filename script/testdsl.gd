extends Node

# Reads DSL file into a string
func load_dsl_file(path: String) -> String:
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Cannot open file: " + path)
		return ""
	var content = file.get_as_text()
	file.close()
	return content


# Parses all chests from the DSL
func parse_chests(dsl: String) -> Array:
	var chests = []
	var blocks = dsl.split("bau_id")

	for block in blocks:
		block = block.strip_edges()
		if block == "":
			continue

		var chest = {}

		# Get chest ID
		var start_id = block.find("\"") + 1
		var end_id = block.find("\"", start_id)
		chest["id"] = block.substr(start_id, end_id - start_id)

		# Get moedas
		var start_block = block.find("{", end_id) + 1
		var end_block = block.find("}", start_block)
		var block_text = block.substr(start_block, end_block - start_block)

		var coins = []
		if block_text.find("random({") != -1:
			var values_text = block_text.get_slice("{", 1).get_slice("}", 0)
			for v in values_text.split(","):
				coins.append(int(v.strip_edges()))
		chest["moedas"] = coins

		chests.append(chest)

	return chests


# Gets a random coin value from a chest
func get_random_coins(chest: Dictionary) -> int:
	var values = chest["moedas"]
	return values[randi() % values.size()]


# Runs when the scene starts
func _ready():
	randomize()
	
	var dsl = load_dsl_file("res://scripts/baus.dsl")
	var chests = parse_chests(dsl)

	for i in range(5):
		print("--------------")
		for chest in chests:
			var coins = get_random_coins(chest)
			print("Baú:", chest["id"], "->", coins, "moedas")
