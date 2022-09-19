extends AudioStreamPlayer

func _process(_delta):
	if !(Input.is_action_pressed("ui_down") || Input.is_action_pressed("ui_right") || Input.is_action_pressed("ui_up") || Input.is_action_pressed("ui_left")):
		#self.playing = false
		$footTimer.start()


func _on_footTimer_timeout():
	self.playing = true
