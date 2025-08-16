extends Node2D

@export var grid_size: int = 3	# N x N
var tiles := []
var correct_order := []
var first_selected: int = -1

@onready var container: GridContainer = $TileContainer

func set_puzzle_image(path: String):
	var tex = load(path)
	_create_tiles(tex)

func _create_tiles(tex: Texture2D):
	container.clear_children()
	tiles.clear()
	correct_order.clear()
	
	container.columns = grid_size
	var tile_size = tex.get_size() / Vector2(grid_size, grid_size)
	var source_image = tex.get_image()
	
	for y in range(grid_size):
		for x in range(grid_size):
			var region = Rect2(tile_size * Vector2(x, y), tile_size)
			
			# Создаем отдельное изображение для тайла
			var tile_image = Image.create(tile_size.x, tile_size.y, false, source_image.get_format())
			tile_image.blit_rect(source_image, region, Vector2.ZERO)
			
			var img_tex = ImageTexture.create_from_image(tile_image)
			
			var btn = TextureButton.new()
			btn.texture_normal = img_tex
			btn.rect_min_size = tile_size
			btn.name = str(y * grid_size + x)
			btn.pressed.connect(Callable(self, "_on_tile_pressed").bind(btn))
			
			container.add_child(btn)
			tiles.append(btn)
			correct_order.append(btn)
	
	_shuffle_tiles()

func _shuffle_tiles():
	tiles.shuffle()
	for i in range(tiles.size()):
		container.move_child(tiles[i], i)

func _on_tile_pressed(btn):
	var index = tiles.find(btn)
	if first_selected == -1:
		first_selected = index
		btn.modulate = Color(1,0.7,0.7)	# подсветка выбранного
	else:
		_swap_tiles(first_selected, index)
		tiles[first_selected].modulate = Color(1,1,1)
		first_selected = -1
		_check_win()

func _swap_tiles(a, b):
	if a == b:
		return
	var temp = tiles[a]
	tiles[a] = tiles[b]
	tiles[b] = temp
	container.move_child(tiles[a], a)
	container.move_child(tiles[b], b)

func _check_win():
	for i in range(tiles.size()):
		if tiles[i] != correct_order[i]:
			return
	print("Пазл собран!")
	_on_win()

func _on_win():
	var win_label = Label.new()
	win_label.text = "Пазл собран!"
	win_label.horizontal_alignment = 1
	win_label.vertical_alignment = 1
	win_label.rect_size = get_viewport_rect().size
	add_child(win_label)
