extends Node
var new_player: bool = true
var discovered = []
var day = []
func load_game():
	if not FileAccess.file_exists("user://save.json"):
		DirAccess.copy_absolute("res://save_template.json","user://save.json")
	
	var save_file = FileAccess.open("user://save.json", FileAccess.READ)
	var json_txt = save_file.get_as_text()
	
	save_file.close()
	
	var json = JSON.new()
	var error = json.parse(json_txt)
	if error == OK:
		var data_received = json.data
		print(data_received)
		new_player = data_received["new_player"]
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_txt, " at line ", json.get_error_line())
