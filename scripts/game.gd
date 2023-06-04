extends Node

const SIDE_MOV_UNITS: int = 1
const DOWN_MOV_UNITS: int = 1
const N_BLOCKS:Array = [4, 4, 4, 4, 4, 1]
const COLORS: Array = ["blue", "green", "purple", "red", "yellow"]
const PIECE_TYPES: int = 6
const INIT_COORDS: Array = [
	[Vector2i(8, 3), Vector2i(8, 2), Vector2i(8, 1), Vector2i(8, 0)],
	[Vector2i(8, 3), Vector2i(8, 2), Vector2i(9, 2), Vector2i(10, 2)],
	[Vector2i(8, 3), Vector2i(9, 3), Vector2i(9, 2), Vector2i(10, 2)],
	[Vector2i(8, 3), Vector2i(8, 2), Vector2i(7, 2), Vector2i(9, 2)],
	[Vector2i(8, 3), Vector2i(9, 3), Vector2i(9, 2), Vector2i(8, 2)],
	[Vector2i(8, 3)]
]
var tetris_map: TetrisMap
var clock: Timer
var piece_collided: bool
var tetris_piece: TetrisPiece
var next_piece_data: Dictionary

# Game control
func _ready():
	"""Set up vars and objects"""
	clock = $Clock
	tetris_map = $TetrisMap
	tetris_piece = TetrisPiece.new()
	next_piece_data = {"type": "", "color": "", "rotated": false}
	start()

func start() -> void:
	randomize()
	piece_collided = false
	get_next_piece_data()
	generate_piece()
	tetris_map.create_blocks(tetris_piece, next_piece_data["color"])
	clock.start()

func play() -> void:
	"""The game continues"""
	pass

func pause() -> void:
	"""Stops the game, all input is deactivate except the one for play and game
	clock is stopped"""
	pass

func reset() -> void:
	"""The game variables go back to their initial state"""
	pass

func game_over() -> void:
	"""Finish the game"""
	pass

func get_next_piece_data() -> void:
	next_piece_data["type"] = randi()%PIECE_TYPES
	next_piece_data["color"] = COLORS.pick_random()
	next_piece_data["rotated"] = bool(randi()%2)

# Input capturing and processing
func process_side_movement(event) -> void:
	var units: int = 0
	if event.is_action_pressed("ui_left"):
		units-=SIDE_MOV_UNITS 
	if event.is_action_pressed("ui_right"):
		units+=SIDE_MOV_UNITS
	tetris_piece.move_horizontal(units)
	if tetris_map.check_block_collision(tetris_piece):
		tetris_piece.move_horizontal(-units)
	else:
		tetris_map.update_moving_blocks_pos(tetris_piece)

func process_rotation(event) -> void:
	if event.is_action_pressed("ui_accept"):
		tetris_piece.rotate()
		if tetris_map.check_block_collision(tetris_piece):
			tetris_piece.rotate()
		else:
			tetris_map.update_moving_blocks_pos(tetris_piece)

func _input(event):
	if not piece_collided:
		process_side_movement(event)
		process_rotation(event)

# Clock Event Response
func _on_clock_timeout() -> void:
	tetris_piece.move_vertical(DOWN_MOV_UNITS)
	if tetris_map.check_block_collision(tetris_piece):
		piece_collided = true
		tetris_piece.move_vertical(-DOWN_MOV_UNITS)
		process_piece_collided()
	else:
		tetris_map.update_moving_blocks_pos(tetris_piece)
		clock.start()

# Collision Processing
func generate_piece() -> void:
	var type: int = next_piece_data["type"]
	var coords: Array = INIT_COORDS[type].duplicate()
	var r_flag: bool = next_piece_data["rotated"]
	tetris_piece.init(N_BLOCKS[type], type, coords, r_flag)

func process_piece_collided() -> void:
	tetris_map.update_map(tetris_piece)
	get_next_piece_data()
	generate_piece()
	tetris_map.create_blocks(tetris_piece, next_piece_data["color"])
	piece_collided = false
	clock.start()
