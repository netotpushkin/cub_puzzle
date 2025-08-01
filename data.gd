extends Node

var difficulty: int = 3       # Размер сетки (3x3 и т.п.)
var image_index: int = 0      # Индекс текущей картинки
var grid_size: int = 3        # Для явности — совпадает с difficulty
var tile_positions := {}      # Словарь: имя плитки → Vector2 позиции

func set_difficulty(value: int) -> void:
	difficulty = value
	grid_size = value
	tile_positions.clear()  # очищаем старые позиции, т.к. сетка другая
	_save_all()

func _save_all():
	var config = ConfigFile.new()

	config.set_value("game", "difficulty", difficulty)
	config.set_value("game", "image_index", image_index)
	config.set_value("game", "grid_size", grid_size)

	# Сохраняем позиции плиток в секции tile_positions
	for tile_name in tile_positions.keys():
		var pos = tile_positions[tile_name]
		config.set_value("tile_positions", tile_name + "_x", pos.x)
		config.set_value("tile_positions", tile_name + "_y", pos.y)

	config.save("user://config.cfg")

func _load_all():
	var config = ConfigFile.new()
	var err = config.load("user://config.cfg")
	if err != OK:
		difficulty = 3
		image_index = 0
		grid_size = difficulty
		tile_positions.clear()
		return

	difficulty = int(config.get_value("game", "difficulty", 3))
	image_index = int(config.get_value("game", "image_index", 0))
	grid_size = int(config.get_value("game", "grid_size", difficulty))

	tile_positions.clear()
	if config.has_section("tile_positions"):
		var keys = config.get_section_keys("tile_positions")
		for key in keys:
			if key.ends_with("_x"):
				var base_name = key.substr(0, key.length() - 2)
				var x = float(config.get_value("tile_positions", key, 0))
				var y = float(config.get_value("tile_positions", base_name + "_y", 0))
				tile_positions[base_name] = Vector2(x, y)
