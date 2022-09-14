extends Node2D

func bullet_spawned(bullet, position, direction, type):
	if type == "pistol":
		add_child(bullet)
		bullet.global_position = position
		bullet.set_direction(direction)
		bullet.set_timer(1)
		bullet.type = "pistol"
	
	if type == "shotgun":
		add_child(bullet)
		bullet.global_position = position
		bullet.set_direction(direction)
		bullet.set_timer(0.3)
		bullet.type = "shotgun"
		
		var bullet2 = bullet.duplicate()
		add_child(bullet2)
		bullet2.global_position = position
		bullet2.set_direction(direction.rotated(PI/8))
		bullet2.set_timer(0.3)
		bullet2.type = "shotgun"
		
		var bullet3 = bullet.duplicate()
		add_child(bullet3)
		bullet3.global_position = position
		bullet3.set_direction(direction.rotated(-PI/8))
		bullet3.set_timer(0.3)
		bullet3.type = "shotgun"
		
		var bullet4 = bullet.duplicate()
		add_child(bullet4)
		bullet4.global_position = position
		bullet4.set_direction(direction.rotated(PI/16))
		bullet4.set_timer(0.3)
		bullet4.type = "shotgun"
		
		var bullet5 = bullet.duplicate()
		add_child(bullet5)
		bullet5.global_position = position
		bullet5.set_direction(direction.rotated(-PI/16))
		bullet5.set_timer(0.3)
		bullet5.type = "shotgun"
		
		var bullet6 = bullet.duplicate()
		add_child(bullet6)
		bullet6.global_position = position
		bullet6.set_direction(direction.rotated(PI/24))
		bullet6.set_timer(0.3)
		bullet6.type = "shotgun"
		
		var bullet7 = bullet.duplicate()
		add_child(bullet7)
		bullet7.global_position = position
		bullet7.set_direction(direction.rotated(-PI/24))
		bullet7.set_timer(0.3)
		bullet7.type = "shotgun"
	
	if type == "burst":	
		add_child(bullet)
		bullet.global_position = position
		bullet.set_direction(direction)
		bullet.set_timer(1)
		bullet.type = "burst"
		
		var bullet2 = bullet.duplicate()
		add_child(bullet2)
		bullet2.global_position = position + position.normalized()
		bullet2.set_direction(direction)
		bullet2.set_timer(1)
		bullet2.type = "burst"
		
		#var bullet3 = bullet.duplicate()
		#add_child(bullet3)
		#bullet3.global_position = position + Vector2(cos(PI), sin(PI)) * 200
		#bullet3.set_direction(direction)
		#bullet3.set_timer(1)
