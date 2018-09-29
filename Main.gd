extends Node2D

#Is emitted when we the tetromino combines with BricksHandler
signal bricks_added(bricks)

const Tetromino = preload("Tetromino/Tetromino.tscn")

#The current tetromino
onready var tetro = $Tetromino

#Holds the current tetrominoes yet to fall
var _rand_tetros = []

func _ready():
	#Every time we play, we randomize the tetrominoes
	randomize()

#Add a new tetromino
func add_tetromino():
	tetro = Tetromino.instance()
	
	tetro.set_type(_next_tetro_shape(tetro.Shapes))
	tetro.connect("collided", self, "tetromino_collided")
	tetro.position = Vector2(128, 0)
	add_child(tetro)

#Calls whenever the tetromino collides with something
func tetromino_collided(collision):
	
	if tetro.is_on_floor() or collision.collider == $BricksHandler:
		
		#Pass the tetromino's bricks to the BricksHandler
		var bricks = []
		for brick in tetro.get_children():
			var of = Vector2(32,32)
			brick.global_position = (brick.global_position+of/2).snapped(of)-of/2
			var new_brick = brick.duplicate()
			new_brick.position = tetro.to_global(new_brick.position)
			new_brick.position = $BricksHandler.to_local(new_brick.position)
			
			bricks.append(new_brick)
			
			#Game Over
			if new_brick.position.y < 0:
				get_tree().quit()
				return
		
		#Remove and replace the tetromino
		tetro.queue_free()
		add_tetromino()
		
		emit_signal("bricks_added", bricks)

#This function computes the next tetromino to fall
func _next_tetro_shape(shapes):
	
	#When _rand_tetros is empty, fill it back up
	if _rand_tetros.empty():
		var size = shapes.get_height() / 4
		for r in range(size*4):
			_rand_tetros.append(r % size)
	
	#Randomly take a shape index out of _rand_tetros
	var next_index = randi() & (_rand_tetros.size()-1)
	var next_tetro = _rand_tetros[next_index]
	_rand_tetros.remove(next_index)
	
	return next_tetro