extends Node
signal got_next_piece(piece, color)
signal score_updated(score)

enum {STOPPED, PLAYING, PAUSED, RESETTED}
const SIDE_MOV_UNITS: int = 1
const DOWN_MOV_UNITS: int = 1
const CLOCK_INIT_TIME: float = 1.0
const CLOCK_MIN_TIME: float = 0.2
const CLOCK_DEC_TIME: float = 1.0/6.0
const MAX_LEVEL: int = 9
const TARGET_COMPLETED_ROWS: int = 20
var tetris_map: TetrisMap
var clock: Timer
var piece_collided: bool
var player_controls_down_mov: bool
var tetris_piece: TetrisPiece
var next_piece: TetrisPiece
var ghost_piece: TetrisPiece
var lvl_handler: LevelHandler
var piece_gen: PieceGenerator
var score_handler: ScoreHandler
var game_state: int

# Game control
func _ready():
	"""Set up vars and objects"""
	clock = $Clock
	tetris_map = $TetrisMap
	ghost_piece = TetrisPiece.new()
	lvl_handler = LevelHandler.new()
	piece_gen = PieceGenerator.new()
	score_handler = ScoreHandler.new()
	set_process_input(false)
	game_state = STOPPED

func generate_piece() -> void:
	var color: String
	if next_piece != null:
		color = piece_gen.next_piece_data['color']
		tetris_piece = next_piece
		next_piece = piece_gen.generate_piece()
		ghost_piece.init(tetris_piece._n_blocks, tetris_piece._type,
		tetris_piece._block_coords.duplicate())
		tetris_map.create_blocks_from(tetris_piece, color)
		color = piece_gen.next_piece_data['color']
		emit_signal("got_next_piece", next_piece, color)
	else:
		next_piece = piece_gen.generate_piece()
		generate_piece()

func start() -> void:
	piece_collided = false
	player_controls_down_mov = false
	piece_gen.init()
	score_handler.init()
	emit_signal("score_updated", score_handler.score)
	next_piece = null
	generate_piece()
	lvl_handler.init()
	update_ghost_piece()
	set_process_input(true)
	clock.wait_time = CLOCK_INIT_TIME
	clock.start()

func play() -> void:
	match game_state:
		STOPPED:
			start()
			game_state = PLAYING
		PAUSED:
			set_process_input(false)
			clock.paused = false
			clock.start()
			game_state = PLAYING

func pause() -> void:
	match game_state:
		PLAYING:
			set_process_input(false)
			clock.paused = true
			game_state = PAUSED

func reset() -> void:
	game_state = RESETTED
	tetris_map.reset()
	start()
	game_state = PLAYING

func game_over() -> void:
	"""Finish the game"""
	set_process_input(false)
	clock.stop()
	print("Game Over")

# Input capturing and processing
func update_ghost_piece() -> void:
	ghost_piece._block_coords = tetris_piece._block_coords.duplicate()
	while true:
		ghost_piece.move_vertical(DOWN_MOV_UNITS)
		if tetris_map.check_block_collision(ghost_piece):
			ghost_piece.revert()
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
		tetris_piece.revert()
	else:
		tetris_map.update_moving_blocks_pos(tetris_piece)

func process_down_movement(event) -> void:
	if event.is_action_pressed("ui_down"):
		player_controls_down_mov = true
		while true:
			tetris_piece.move_vertical(DOWN_MOV_UNITS)
			if tetris_map.check_block_collision(tetris_piece):
				piece_collided = true
				tetris_piece.revert()
				tetris_map.update_moving_blocks_pos(tetris_piece)
				process_piece_collided()
				break
	player_controls_down_mov = false

func process_rotation(event) -> void:
	if event.is_action_pressed("ui_accept"):
		tetris_piece.rotate()
		if tetris_map.check_block_collision(tetris_piece):
			tetris_piece.revert()
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
func process_piece_collided() -> void:
	tetris_map.update_map(tetris_piece)
	if tetris_map.has_blocks_in_hidden_zone():
		game_over()
	else:
		generate_piece()
		update_ghost_piece()
		piece_collided = false
		score_handler.update_score(tetris_map.n_rows_cleared)
		emit_signal("score_updated", score_handler.score)
		if lvl_handler.get_to_next_lvl(tetris_map.n_rows_cleared):
			clock.wait_time-=CLOCK_DEC_TIME
			clock.wait_time = clampf(clock.wait_time, CLOCK_MIN_TIME, 1.0)
			score_handler.update_points_per_row()
		clock.start()
