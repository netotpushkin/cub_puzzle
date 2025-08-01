extends Control

func _ready():
	$VBoxContainer/Button.pressed.connect(_on_play_pressed)
	$VBoxContainer/Button2.pressed.connect(_on_settings_pressed)
	$VBoxContainer/Button3.pressed.connect(_on_quit_pressed)

func _on_play_pressed():
	get_tree().change_scene_to_file("res://start.tscn") # путь к твоей игровой сцене

func _on_settings_pressed():
	get_tree().change_scene_to_file("res://settings.tscn")

func _on_quit_pressed():
	get_tree().quit()
