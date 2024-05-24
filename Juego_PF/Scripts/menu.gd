extends VBoxContainer

const WORLD = preload("res://World.tscn")

func _on_new_game_b_pressed():
	get_tree().change_scene_to_packed(WORLD)



func _on_quit_b_pressed():
	get_tree().quit()
