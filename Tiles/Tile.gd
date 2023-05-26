extends Node2D

func _on_button_pressed():
	get_parent().get_parent().tile_clicked.emit(global_position)
