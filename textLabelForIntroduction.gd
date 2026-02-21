extends RichTextLabel

var textPosition = 0

func _process(delta: float) -> void:
	#Loads the text over time and gets the text position to see if the next character is a , or . to slow down the loading speed
	#If enter is pressed, the full text is loaded instantly
	#If all text is shown, makes the continue button visible 
	if get_parent().visible == false:
		visible_ratio = 0
	else:
		if Input.is_action_just_pressed("ui_text_submit"):
			visible_ratio = 1
		textPosition = round(visible_ratio * text.length())
		if text.count(",",textPosition - 1,textPosition) == 0 && text.count(".",textPosition - 1,textPosition) == 0:
			visible_ratio += delta / text.length() * 30
		else:
			visible_ratio += delta / text.length() * 10
		if visible_ratio == 1:
			self.get_parent().get_child(1).visible = true
		else:
			self.get_parent().get_child(1).visible = false
