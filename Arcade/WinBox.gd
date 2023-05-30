extends Panel

@export var disabledPos:Vector2
@export var enabledPos:Vector2
var storedScores:Array[Array] = [[], [], []]

#Score format:
var scoreToSave = {
	"score": -1,								# move amount
	"name": "[null]",							# inputted name
	"when": Time.get_unix_time_from_system(),	# when has score been made
	"moves": [],								# Array of movements
	"totaltime": -1.0,							# Total time spent in seconds
}
@export var specialColors:Array[StyleBox]
var mapID = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	position = disabledPos
	visible = false
#	init_score()
#	reload_score_display()
	pass # Replace with function body.

func change_visibility(vis:bool):
	var tween = create_tween()
	if vis:
		visible = true
		position = disabledPos
		tween.tween_property(self, "position", enabledPos, 0.5).set_trans(Tween.TRANS_CIRC)
		var formatTime = TimeFormatter.format_time(scoreToSave["totaltime"],TimeFormatter.TimeFormat.FORMAT_SECONDS|TimeFormatter.TimeFormat.FORMAT_MINUTES)
		$ScoreRegisterField/InputField.text = ""
		if scoreToSave["score"] > 0:
			$ScoreRegisterField/ScorePreview.text = str(scoreToSave["score"]) + " (" + formatTime + ")"
			$ScoreRegisterField/InputField.editable = true
			$ScoreRegisterField/ScoreRegisterLabel.text = "Ajoutez votre score au classement!"
			$Cancel.disabled = false
			if len(storedScores[mapID]) > 0:
				if scoreToSave["score"] < storedScores[mapID][0]["score"]:
					$Label.text = "NEW BEST!"
				elif scoreToSave["score"] == storedScores[mapID][0]["score"] and scoreToSave["totalTime"] < storedScores[mapID][0]["totalTime"]:
					$Label.text = "NEW BEST?"
				else:
					$Label.text = "GAME OVER"
			else:
				$Label.text = "FIRST CLEAR!"
		else:
			$ScoreRegisterField/ScorePreview.text = "DNF"
			$Label.text = "LEADERBOARD"
			$ScoreRegisterField/ScoreRegisterLabel.text = "Vous devez avoir fini le niveau pour enregistrer votre score!"
			$Cancel.disabled = true
		await get_tree().create_timer(0.5).timeout
	else:
		position = enabledPos
		tween.tween_property(self, "position", disabledPos, 0.5).set_trans(Tween.TRANS_CIRC)
		$ScoreRegisterField/InputField.editable = false
		await get_tree().create_timer(0.5).timeout
		visible = false
	
func init_score():
	if FileAccess.file_exists("user://" + str(mapID) + ".dat"):
		load_scores()
	else:
		storedScores[mapID] = []
		var file = FileAccess.open("user://" + str(mapID) + ".dat", FileAccess.WRITE)
		file.store_string(JSON.stringify(storedScores[mapID]))

func reload_score_display():
	print(storedScores[mapID])
	storedScores[mapID].sort_custom(func(a, b): if a["score"] == b["score"]: return a["totaltime"] < b["totaltime"] else: return a["score"] < b["score"])
	
	var container = $ScoreDatabase/VBoxContainer
	for child in container.get_children():
		child.queue_free()
	
	var textlboard = $"../Panel/Leaderboard/RichTextLabel"
	
	textlboard.text = ""
	
	if len(storedScores[mapID]) == 0:
		textlboard.text = "Aucun score n'a été posté pour ce niveau pour le moment!"
	
	for i in range(len(storedScores[mapID])):
		var score = storedScores[mapID][i]
		var scoreObject = preload("res://Arcade/ScoreThing.tscn")
		var scobj = scoreObject.instantiate()
		var formatTime = TimeFormatter.format_time(score["totaltime"],TimeFormatter.TimeFormat.FORMAT_SECONDS|TimeFormatter.TimeFormat.FORMAT_MINUTES)
		scobj.get_child(1).text = score["name"]
		scobj.get_child(2).text = str(score["score"]) + " (" + formatTime + ")"
		scobj.get_child(3).text = "N°"+str(i+1)
		if i < len(specialColors):
			scobj.get_child(0).set("theme_override_styles/panel", specialColors[i])
		container.add_child(scobj)
		var croppedText = score["name"].left(60)
		if croppedText != score["name"]:
			croppedText += "..."
		if i < 20:
			textlboard.text += "#{3}: {0} / {2} / {1}\n".format([score["score"], croppedText, formatTime, i+1])
		pass
	
func save_score(score):
	storedScores[mapID].append(score)
	reload_score_display()
	var file = FileAccess.open("user://" + str(mapID) + ".dat", FileAccess.WRITE)
	file.store_string(JSON.stringify(storedScores[mapID]))
	
func load_scores():
	var file = FileAccess.open("user://" + str(mapID) + ".dat", FileAccess.READ)
	storedScores[mapID] = JSON.parse_string(file.get_as_text())
	
func set_player_name(name:String = "[null]"):
	if $ScoreRegisterField/InputField.editable:
		scoreToSave["name"] = name
		$ScoreRegisterField/InputField.editable = false
		save_score(scoreToSave)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
