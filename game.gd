extends Node2D

var images := [
	"res://img/1.png",
	"res://img/2.png",
	"res://img/3.png"
]

var current_image_index := 0
var tile_size: Vector2
var pieces := []
var positions := []
var correct_positions := {}
var selected_piece = null
var button_pressed := false

func _ready():
	Data._load_all()

	current_image_index = Data.image_index
	var GRID_SIZE = Data.difficulty

	_load_puzzle(GRID_SIZE, current_image_index)

	$Button.connect("pressed", Callable(self, "_on_button_pressed"))
	$Button.connect("released", Callable(self, "_on_button_released"))
	$Button2.connect("pressed", Callable(self, "_on_back_pressed"))
	$ContinueButton.connect("pressed", Callable(self, "_on_ContinueButton_pressed"))

	$CompletionLabel.visible = false
	$ContinueButton.visible = false

func _process(_delta):
	if $Button.is_pressed():
		if not button_pressed:
			button_pressed = true
			_hide_pieces()
	else:
		if button_pressed:
			button_pressed = false
			_show_pieces()

func _load_puzzle(grid_size: int, image_index: int):
	_clear_puzzle()

	var texture: Texture2D = load(images[image_index])
	var image: Image = texture.get_image()
	var full_size: Vector2 = texture.get_size()
	tile_size = full_size / grid_size

	$Sprite2D.texture = texture
	$Sprite2D.position = get_viewport_rect().size / 2
	$Sprite2D.centered = true

	var puzzle_size = tile_size * grid_size
	var puzzle_origin = $Sprite2D.position - puzzle_size / 2

	_create_tiles(grid_size, puzzle_origin, image)

	# Если есть сохранённые позиции — восстановить
	if Data.tile_positions.size() > 0:
		_restore_positions_from_save()
	else:
		# Иначе перемешать плитки
		_shuffle_positions()

func _clear_puzzle():
	for piece in pieces:
		remove_child(piece)
	pieces.clear()
	positions.clear()
	correct_positions.clear()
	selected_piece = null

func _create_tiles(grid_size: int, puzzle_origin: Vector2, image: Image):
	for y in range(grid_size):
		for x in range(grid_size):
			var region = Rect2(x * tile_size.x, y * tile_size.y, tile_size.x, tile_size.y)
			var piece_image: Image = image.get_region(region)
			var piece_texture: ImageTexture = ImageTexture.create_from_image(piece_image)

			var btn = TextureButton.new()
			btn.texture_normal = piece_texture
			btn.position = puzzle_origin + Vector2(x, y) * tile_size
			btn.pivot_offset = tile_size / 2
			btn.name = "tile_%d_%d" % [x, y]
			btn.connect("pressed", Callable(self, "_on_piece_pressed").bind(btn))
			add_child(btn)

			pieces.append(btn)
			positions.append(btn.position)
			correct_positions[btn] = btn.position

func _restore_positions_from_save():
	for btn in pieces:
		if Data.tile_positions.has(btn.name):
			btn.position = Data.tile_positions[btn.name]

func _shuffle_positions():
	positions.shuffle()
	for i in range(pieces.size()):
		pieces[i].position = positions[i]

func _hide_pieces():
	for piece in pieces:
		piece.visible = false

func _show_pieces():
	for piece in pieces:
		piece.visible = true

func _on_piece_pressed(btn):
	if selected_piece == null:
		selected_piece = btn
		selected_piece.get_parent().move_child(selected_piece, selected_piece.get_parent().get_child_count() - 1)
		selected_piece.scale = Vector2(1.2, 1.2)
	else:
		var temp_pos = selected_piece.position
		selected_piece.position = btn.position
		btn.position = temp_pos
		selected_piece.scale = Vector2(1, 1)
		selected_piece = null

		_check_puzzle_completed()
		_save_progress()

func _check_puzzle_completed():
	for piece in pieces:
		if piece.position != correct_positions[piece]:
			return
	_show_completion_message()

func _show_completion_message():
	for piece in pieces:
		piece.disabled = true

	$Button.visible = false
	$CompletionLabel.z_index = 100
	$CompletionLabel.visible = true
	$ContinueButton.visible = true

func _on_ContinueButton_pressed():
	current_image_index = (current_image_index + 1) % images.size()
	Data.image_index = current_image_index
	_load_puzzle(Data.difficulty, current_image_index)
	$CompletionLabel.visible = false
	$ContinueButton.visible = false
	$Button.visible = true
	_save_progress()

func _on_back_pressed():
	_save_progress()
	get_tree().change_scene_to_file("res://main.tscn")

func _save_progress():
	Data.tile_positions.clear()
	for btn in pieces:
		Data.tile_positions[btn.name] = btn.position
	Data.image_index = current_image_index
	Data.grid_size = Data.difficulty
	Data._save_all()
