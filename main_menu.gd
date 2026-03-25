extends Control
var at_message: bool = false
func _ready() -> void:
	save.load_game()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if save.new_player:
			if at_message:
				$AnimationPlayer.play("from_description")
			else:
				at_message = true
				$AnimationPlayer.play("description_of_world")
		else:
			$AnimationPlayer.play("from_screen")




func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name in ["from_description", "from_screen"]:
		get_tree().change_scene_to_file("res://game_scene.tscn")
