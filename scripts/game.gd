extends Node

const SIDE_MOV_UNITS: int = 1
const DOWN_MOV_UNITS: int = 1
const CLOCK_INIT_TIME: float = 1.0
const CLOCK_MIN_TIME: float = 0.2
const CLOCK_DEC_TIME: float = 1.0/6.0
const N_BLOCKS:Array = [4, 4, 4, 4, 4, 1]
const COLORS: Array = ["blue", "green", "purple", "red", "yellow"]
const PIECE_TYPES: int = 6
const MAX_LEVEL: int = 9
const TARGET_COMPLETED_ROWS: int = 20
const INIT_COORDS: Array = [
	[Vector2i(4, 3), Vector2i(4, 2), Vector2i(4, 1), Vector2i(4, 0)],
	[Vector2i(4, 3), Vector2i(4, 2), Vector2i(5, 2), Vector2i(6, 2)],
	[Vector2i(4, 3), Vector2i(5, 3), Vector2i(5, 2), Vector2i(6, 2)],
	[Vector2i(4, 3), Vector2i(4, 2), Vector2i(3, 2), Vector2i(5, 2)],
	[Vector2i(4, 3), Vector2i(5, 3), Vector2i(5, 2), Vector2i(4, 2)],
	[Vector2i(4, 3)]
]
var tetris_map: TetrisMap
var clock: Timer
var piece_collided: bool
var player_controls_down_mov: bool
var tetris_piece: TetrisPiece
var ghost_piece: TetrisPiece
var lvl_handler: LevelHandler
var next_piece_data: Dictionary

# Game control
func _ready():
	"""Set up vars and objects"""
	clock = $Clock
	tetris_map = $TetrisMap
	tetris_piece = TetrisPiece.new()
	ghost_piece = TetrisPiece.new()
	lvl_handler = LevelHandler.new()
	next_piece_data = {"type": "", "color": "", "rotated": false}
	set_process_input(false)
	start()

func start() -> void:
	randomize()
	piece_collided = false
	player_controls_down_mov = false
	get_next_piece_data()
	generate_piece()
	lvl_handler.init()
	tetris_map.create_blocks_from(tetris_piece, next_piece_data["color"])
	update_ghost_piece()
	set_process_input(true)
	clock.wait_time = CLOCK_INIT_TIME
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
	set_process_input(false)
	clock.stop()
	print("Game Over")

func get_next_piece_data() -> void:
	next_piece_data["type"] = randi()%PIECE_TYPES
	next_piece_data["color"] = COLORS.pick_random()
	next_piece_data["rotated"] = bool(randi()%2)

# Input capturing and processing
func update_ghost_piece() -> void:
	ghost_piece._block_coords = tetris_piece._block_coords.duplicate()
	while true:
		ghost_piece.move_vertical(DOWN_MOV_UNITS)
		if tetris_map.check_block_collision(ghost_piece):
			ghost_piece.move_vertical(-DOWN_MOV_UNITS)
			tetris_map.update_ghost_blocks_pos(ghost_piece)
			break

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

func process_down_movement(event) -> void:
	if event.is_action_pressed("ui_down"):
		player_controls_down_mov = true
		while true:
			tetris_piece.move_vertical(DOWN_MOV_UNITS)
			if tetris_map.check_block_collision(tetris_piece):
				piece_collided = true
				tetris_piece.move_vertical(-DOWN_MOV_UNITS)
				tetris_map.update_moving_blocks_pos(tetris_piece)
				process_piece_collided()
				break
		player_controls_down_mov = false

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
		process_down_movement(event)
		process_rotation(event)
		update_ghost_piece()

# Clock Event Response
func _on_clock_timeout() -> void:
	if not player_controls_down_mov:
		tetris_piece.move_vertical(DOWN_MOV_UNITS)
		if tetris_map.check_block_collision(tetris_piece):
			piece_collided = true
			tetris_piece.move_vertical(-DOWN_MOV_UNITS)
			process_piece_collided()
		else:
			tetris_map.update_moving_blocks_pos(tetris_piece)
			update_ghost_piece()
			clock.start()

# Collision Processing
func generate_piece() -> void:
	var type: int = next_piece_data["type"]
	var coords: Array = INIT_COORDS[type].duplicate()
	var r_flag: bool = next_piece_data["rotated"]
	tetris_piece.init(N_BLOCKS[type], type, coords, r_flag)
	ghost_piece.init(N_BLOCKS[type], type, coords.duplicate(), r_flag)

func process_piece_collided() -> void:
	tetris_map.update_map(tetris_piece)
	if tetris_map.has_blocks_in_hidden_zone():
		game_over()
	else:
		get_next_piece_data()
		generate_piece()
		tetris_map.create_blocks_from(tetris_piece, next_piece_data["color"])
		update_ghost_piece()
		piece_collided = false
		if lvl_handler.get_to_next_lvl(tetris_map.n_rows_cleared):
			clock.wait_time-=CLOCK_DEC_TIME
			clock.wait_time = clampf(clock.wait_time, CLOCK_MIN_TIME, 1.0)
			print("CLOCK TIME", clock.wait_time)
		clock.start()
