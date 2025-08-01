extends Control

func _ready():
	$VBoxContainer/Button.pressed.connect(Callable(self, "_on_back_pressed"))
	$VBoxContainer/OptionButton.item_selected.connect(Callable(self, "_on_difficulty_selected"))
	
	var current_difficulty = Data.difficulty
	var index = current_difficulty - 3
	if index >= 0 and index < $VBoxContainer/OptionButton.get_item_count():
		$VBoxContainer/OptionButton.select(index)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://main.tscn")

func _on_difficulty_selected(index):
	var selected = index + 3
	Data.set_difficulty(selected)
