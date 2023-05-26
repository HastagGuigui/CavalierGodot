extends TileMap


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func fill_moves(movearray:Array[Vector2i], showKnight = true):
	clear_layer(0)
	if showKnight:
		set_cell(0, Vector2i.ZERO, 2, Vector2i.ZERO, 0)
	for move in movearray:
		print(move)
		set_cell(0, Vector2i(move), 1, Vector2i.ZERO, 0)
		set_cell(0, Vector2i(-move), 1, Vector2i.ZERO, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
