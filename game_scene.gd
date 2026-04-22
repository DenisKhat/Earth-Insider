extends Control
var animal_name: String
var scientific_name: String
var description: String
var real_name: String
var scrambled_name: String
var real_description: String
var stage_of_game = 0
var guess: String
var finished: bool
const REVEAL_PROB = 0.4

func _ready() -> void:
	finished = false
	stage_of_game = 0
	# Select a random animal... Eventually do this better with saving/etc, for now just hard code it.
	var number_generator = RandomNumberGenerator.new()
	var random_id = number_generator.randi_range(1, 2778)
	load_animal(random_id)
	$Description.text = description
	$LatinName.text = scientific_name
	

func advance_stage():
	var stage_name = $status_bar.order[stage_of_game-1]	
	$status_bar/AnimationPlayer.play(stage_name)
	
	match stage_name:
		"AfterEarth": # Show picture
			$AnimationPlayer.play("Show Image")
		"AfterCamera": # Reveal latin name 
			$AnimationPlayer.play("Show Latin")
		"AfterLambda": # Reveal some letters
			$Name.text = scrambled_name
		
	
func load_animal(id: int):
	# There are 2778 animals, with 1 header line, id should range from 1 to 2778
	var animals_file = FileAccess.open("res://animals.txt", FileAccess.READ)
	for i in range(0,id):
		animals_file.get_line()
	var animal_info = animals_file.get_csv_line()
	animals_file.close()
	# Structure of CSV: [name, scientific_name, description, image_url, cleaned_name, cleaned_description ]
	animal_name = animal_info[4]
	scientific_name = animal_info[1] 
	if scientific_name == "NA":
		scientific_name = ""
	description = animal_info[5]
	real_description = animal_info[2]
	real_name = animal_info[0]
	#Now we come up with the scrambled name and blank space names
	scrambled_name = ""
	var hidden_name = ""
	var number_generator = RandomNumberGenerator.new()
	for char in animal_name.to_upper():
		if char == " ":
			scrambled_name += " "
			hidden_name += " "
		else:
			hidden_name += "_"
			if number_generator.randf() < REVEAL_PROB:
				scrambled_name += char
			else:
				scrambled_name += "_"
	$Name.text = hidden_name
	# Dowload the image and store it.
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)

	# Perform the HTTP request. The URL below returns a PNG image as of writing.
	var error = http_request.request(animal_info[3])
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	
func _http_request_completed(result, response_code, headers, body):
	#print("Getting Image of Animal")
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Image couldn't be downloaded. Try a different image.")

	var image = Image.new()
	var error = image.load_jpg_from_buffer(body)
	if error != OK:
		push_error("Couldn't load the image.")

	var texture = ImageTexture.create_from_image(image)

	# Display the image in a TextureRect node.
	$TextureRect.texture = texture

func _on_word_entry_text_submitted(new_text: String) -> void:
	# Check if guess was correct
	if not finished:
		stage_of_game = stage_of_game + 1
		if new_text == animal_name.to_upper(): # need a more robust checking likely
			# WIN THE GAME
			$Win.play()
			$Name.text = real_name
			$Description.text = real_description
			$AnimationPlayer.play("Win")
			
		elif stage_of_game >= 7:
			# END THE GAME
			$Lose.play()
			$Name.text = real_name
			$Description.text = real_description
			$AnimationPlayer.play("Lose")
		else:
			advance_stage()
		
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and finished:
		get_tree().change_scene_to_file("res://game_scene.tscn")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name in ["Win", "Lose"]:
		finished = true
