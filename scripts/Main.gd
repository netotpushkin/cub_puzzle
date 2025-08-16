extends Node2D

@onready var grid: GridContainer = null

func _ready():
	# Создаём GridContainer через скрипт
	grid = GridContainer.new()
	grid.columns = 3  # Количество колонок
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(grid)

	# Получаем размер экрана
	var screen_size = get_viewport_rect().size
	var columns = grid.columns
	var btn_size = Vector2(screen_size.x / columns - 20, screen_size.x / columns - 20)

	# Загружаем картинки из папки
	var dir = DirAccess.open("res://assets/images")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir() and file_name.get_extension().to_lower() in ["png", "jpg"]:
				var tex = load("res://assets/images/" + file_name)
				var btn = TextureButton.new()
				btn.texture_normal = tex
				btn.custom_minimum_size = btn_size
				btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
				btn.pressed.connect(Callable(self, "_on_image_selected").bind(file_name))
				grid.add_child(btn)
			file_name = dir.get_next()
		dir.list_dir_end()

func _on_image_selected(file_name: String):
	var puzzle_scene = load("res://scenes/Puzzle.tscn").instantiate()
	puzzle_scene.set_puzzle_image("res://assets/images/" + file_name)
	get_tree().change_scene_to(puzzle_scene)
