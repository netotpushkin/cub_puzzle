extends Control

@onready var grid: GridContainer = $GridContainer

func _ready():
	var dir = DirAccess.open("res://assets/images")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir() and file_name.get_extension().to_lower() in ["png", "jpg"]:
				var tex = load("res://assets/images/" + file_name)
				var btn = TextureButton.new()
				btn.texture_normal = tex
				btn.rect_min_size = Vector2(150,150)	# размер кнопки выбора
				btn.pressed.connect(Callable(self, "_on_image_selected").bind(file_name))
				grid.add_child(btn)
			file_name = dir.get_next()
		dir.list_dir_end()

func _on_image_selected(file_name: String):
	var puzzle_scene = load("res://scenes/Puzzle.tscn").instantiate()
	puzzle_scene.set_puzzle_image("res://assets/images/" + file_name)
	get_tree().change_scene_to(puzzle_scene)
