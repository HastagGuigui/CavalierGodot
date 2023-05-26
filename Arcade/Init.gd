extends Node2D

var levels = [
	"res://Arcade/Levels/Level1.tscn",
	"res://Arcade/Levels/Level2.tscn"
]
@onready var background = $Camera/Sprite2D
@export var colors:Array[Color]
var level:PackedScene
var lvlid:int = 0
var curLevelNode:Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	_load_level(0)
	pass # Replace with function body.

func _load_level(id):
	if curLevelNode != null:
		curLevelNode.queue_free()
	lvlid = id
	level = load(levels[id])
	curLevelNode = level.instantiate()
	add_child(curLevelNode)
	background.modulate = colors[randi_range(0,len(colors)-1)]
	$CanvasLayer/WinBox.mapID = id
	$CanvasLayer/WinBox.init_score()
	$CanvasLayer/WinBox.reload_score_display()
	
func reload_level():
	_load_level(lvlid)
	
func load_random_level():
	var lvl = randi_range(0,len(levels)-1)
	_load_level(lvl)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("showLeaderboardDebug"):
		$CanvasLayer/WinBox.change_visibility(not visible)
	if Input.is_action_just_pressed("reloadLevel"):
		reload_level()
	if Input.is_action_just_pressed("nextLevel"):
		_load_level((lvlid + 1)%len(levels))
	if Input.is_action_just_pressed("prevLevel"):
		_load_level((lvlid - 1)%len(levels))
	pass
