extends Node2D

signal tile_clicked(Vector2)
@onready var tm = $TileMap
@onready var knight = $"../Knight"
var knightPos:Vector2i = Vector2i(0,0)
@export var knightMoves:Array[Vector2i] = [
	Vector2i(-2, 1),
	Vector2i(-1, 2),
	Vector2i(2, 1),
	Vector2i(1, 2),
]
var canPickPos = true
var moveCount = 0
var casesWeWentTo:Array[Vector2i] = []
var targets:Array[Vector2i] = []
var moves:Array[Vector2i] = []
var beginTime:float = 0.0
var endTime:float = 0.0
var chronoTimer:float = 0.0
@onready var TextMoveCount = $"../CanvasLayer/Panel/Data Move Count"
@onready var TextCompletePercent = $"../CanvasLayer/Panel/Data Complete Percentage"
@onready var TextCompleteAmount = $"../CanvasLayer/Panel/Data Complete Amount"
@onready var TextTimer = $"../CanvasLayer/Panel/Data Timer"
@export var checkedTex:Texture
var checkLabels:Array[Sprite2D] = []
@export var spawnpoint:Vector2i = Vector2i(-5, -6)
# Called when the node enters the scene tree for the first time.
func _ready():
	targets = tm.get_used_cells(0)
	knightPos = spawnpoint
	knight.position = tm.map_to_local(knightPos)
	print("Knight Position: " + str(knightPos))
	spawnpoint = knightPos
	on_tile_clicked(knight.position, true)
	$"../CanvasLayer/PossibleMoves/TileMap".fill_moves(knightMoves)
	knight.get_child(0).fill_moves(knightMoves, false)
	pass # Replace with function body.

func reset_game():
	for i in checkLabels:
		i.queue_free()
	checkLabels.clear()
	casesWeWentTo.clear()
	knightPos = spawnpoint
	moveCount = 0
	moves.clear()
	beginTime = 0
	endTime = 0
	chronoTimer = 0
	canPickPos = true
	on_tile_clicked(tm.map_to_local(knightPos), true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if moveCount > 1 and endTime <= 0:
		chronoTimer += delta
	TextMoveCount.text = str(moveCount)
	TextCompletePercent.text = str(round(float(len(casesWeWentTo))/float(len(targets))*1000.0)/10)+"%"
	TextCompleteAmount.text = "("+ str(len(casesWeWentTo)) + "/" + str(len(targets)) + ")"
	TextTimer.text = TimeFormatter.format_time(chronoTimer, TimeFormatter.TimeFormat.FORMAT_LESS_THAN_AN_HOUR)
	pass

func on_tile_clicked(pos, force = false):
	if canPickPos:
		var tileClicked = tm.local_to_map(pos)
		for move in knightMoves:
#			print("Testing either " + str(knightPos+move) + " or "+ str(knightPos-move))
			if knightPos + move == tileClicked or knightPos - move == tileClicked or force:
				moves.append(tileClicked)
				if tileClicked not in casesWeWentTo:
					casesWeWentTo.append(tileClicked)
					var label = Sprite2D.new()
					label.position = tm.map_to_local(tileClicked)
					label.modulate = Color(1,1,1,0.5)
					label.texture = checkedTex
					label.scale = Vector2(0.5,0.5)
					label.z_index = 1
					add_child(label)
					checkLabels.append(label)
				if beginTime == 0 and not force:
					beginTime = Time.get_unix_time_from_system()
				moveCount += 1
#				print("you can move here")
				knightPos = tileClicked
				canPickPos = false
				var tween = create_tween()
				tween.tween_property(knight, "position", tm.map_to_local(tileClicked), 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
				await get_tree().create_timer(0.5).timeout
				if len(casesWeWentTo) < len(targets):
					canPickPos = true
				else:
					endTime = Time.get_unix_time_from_system()
					print("Finished!")
					var winbox = $"../CanvasLayer/WinBox"
					winbox.scoreToSave =  {
						"score": moveCount,							# move amount
						"name": "[null]",							# inputted name
						"when": Time.get_unix_time_from_system(),	# when has score been finished
						"moves": moves,								# Array of movements
						"totaltime": endTime-beginTime,				# Total time spent in seconds
					}
					winbox.change_visibility(true)
				break
