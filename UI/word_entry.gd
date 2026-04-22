extends LineEdit


func _on_text_changed(new_text: String) -> void:
	self.text = new_text.to_upper()
	self.set_caret_column(max_length)
