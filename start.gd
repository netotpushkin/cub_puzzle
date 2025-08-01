extends Node2D

const IMAGE_FOLDER := "res://img/"

@onready var grid := $Control/ScrollContainer/GridContainer

func _ready():
	var dir = DirAccess.open(IMAGE_FOLDER)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".png"):
				_add_image_button(IMAGE_FOLDER + file_name)
			file_name = dir.get_next()
		dir.list_dir_end()

func _add_image_button(image_path: String):
	var button = TextureButton.new()
	button.texture_normal = _get_scaled_texture(image_path, Vector2(200, 200))
	
	grid.add_child(button)
	button.connect("pressed", Callable(self, "_on_image_selected").bind(image_path))

func _on_image_selected(image_path: String):
	# По имени файла определим индекс
	var index = _get_image_index(image_path)
	if index >= 0:
		Data.image_index = index
		Data._save_all()
		get_tree().change_scene_to_file("res://game.tscn")

func _get_image_index(image_path: String) -> int:
	var dir := DirAccess.open(IMAGE_FOLDER)
	if dir == null:
		return -1

	var files := []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".png"):
			files.append(file_name)
		file_name = dir.get_next()

	files.sort()  # Чтобы индексы были одинаковыми
	var base_name = image_path.get_file()
	return files.find(base_name)

func _get_scaled_texture(image_path: String, size: Vector2) -> Texture2D:
	var img = Image.new()
	img.load(image_path)
	img.resize(int(size.x), int(size.y), Image.INTERPOLATE_LANCZOS)
	var tex = ImageTexture.create_from_image(img)
	return tex
