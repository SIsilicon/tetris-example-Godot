extends StaticBody2D

func _bricks_added(new_bricks):
	
	#Add bricks to this node and the bricks group
	for brick in new_bricks:
		add_child(brick)
		brick.add_to_group("bricks")
	
	#Get bricks and sort them from top to bottom
	var bricks = get_tree().get_nodes_in_group("bricks")
	bricks.sort_custom(self, "_sort_by_y")
	
	#Remove any complete rows
	var current_y = -1
	var rows_erased = []
	var bricks_processed = []
	for brick in bricks:
		if brick.position.y != current_y:
			current_y = brick.position.y
			bricks_processed = []
		
		bricks_processed.append(brick)
		#OS.window_size.x / 32 gives the
		#number of rows in the play area
		if bricks_processed.size() >= OS.window_size.x / 32:
			for p_brick in bricks_processed:
				p_brick.queue_free()
			bricks_processed = []
			rows_erased.append(current_y)
	
	#Move remaining bricks down
	for row in rows_erased:
		for brick in bricks:
			if brick.position.y < row:
				brick.position.y += 32

#Used to sort the bricks by y position
func _sort_by_y(a, b):
	return a.position.y < b.position.y