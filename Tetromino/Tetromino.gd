tool
extends KinematicBody2D

#Values used in movement
enum {FALL_SPEED = 100, DROP_SPEED = 400, CONTROL_SPEED = 200}

#This texture holds all possible 
#Tetromino shapes along with colours
const Shapes = preload("res://Tetrominoes.png")

var type = 0 setget set_type

#Emitted when colliding with something
signal collided(collision)

func _process(delta):
	if not Engine.editor_hint:
		
		var lv = Vector2(0, FALL_SPEED)
		
		#Move left, right, or fall faster
		if Input.is_action_pressed("ui_left"):
			lv.x -= CONTROL_SPEED
		if Input.is_action_pressed("ui_right"):
			lv.x += CONTROL_SPEED
		if Input.is_action_pressed("ui_down"):
			lv.y = DROP_SPEED
		
		#Rotate the brick positions
		if Input.is_action_just_pressed("ui_up"):
			for brick in get_children():
				brick.position = Vector2(brick.position.y, -brick.position.x)
		
		#Move, and if we collide with something, emit a signal
		move_and_slide(lv, Vector2(0, -20))
		if get_slide_count():
			emit_signal("collided", get_slide_collision(0))
		

func set_type(t):
	type = t
	
	#Remove current bricks to make room for new ones
	for i in get_children():
		i.queue_free()
	
	#Get the shape determined by type
	var shapes = Shapes.get_data().get_rect(Rect2(0, t*4, 4, 4))
	shapes.lock()
	
	for y in range(0, 4):
		for x in range(0, 4):
			var colour = shapes.get_pixel(x, y)
			
			#Make a brick where the pixel is opaque
			if colour.a:
				var new_brick = preload("Brick.tscn").instance()
				new_brick.translate(Vector2( \
				range_lerp(x, 0, 3, -48, 48),\
				range_lerp(y, 0, 3, -48, 48)))
				add_child(new_brick)
				
				#Set the color of the tetromino's brick
				#Blend with white to wash the color a bit
				new_brick.get_node("Diffuse").modulate = \
				colour.blend(Color(1,1,1, 0.25))
	
	shapes.unlock()



