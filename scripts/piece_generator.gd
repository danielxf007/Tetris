extends Node

class_name PieceGenerator

const PIECE_TYPES: int = 6
const N_BLOCKS:Array = [4, 4, 4, 4, 4, 1]
const COLORS: Array = ["blue", "green", "purple", "red", "yellow"]
const INIT_COORD: Vector2i = Vector2i(4, 3)
const PIECE_SHAPES: Array = [
	[Vector2i(), Vector2i(0, -1), Vector2i(0, -2), Vector2i(0, -3)],
	[Vector2i(), Vector2i(0, -1), Vector2i(1, -1), Vector2i(2, -1)],
	[Vector2i(), Vector2i(1, 0), Vector2i(1, -1), Vector2i(2, -1)],
	[Vector2i(), Vector2i(0, -1), Vector2i(-1, -1), Vector2i(1, -1)],
	[Vector2i(), Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1)],
	[Vector2i()]
]
var current_piece_data: Dictionary
var next_piece_data: Dictionary

func init() -> void:
	randomize()
	next_piece_data = generate_piece_data()

func generate_piece_data() -> Dictionary:
	var piece_data: Dictionary = {}
	piece_data["type"] = randi()%PIECE_TYPES
	piece_data["color"] = COLORS.pick_random()
	piece_data["shape"] = PIECE_SHAPES[piece_data["type"]]
	piece_data["rotated"] = bool(randi()%2)
	return piece_data

func generate_piece() -> TetrisPiece:
	current_piece_data = next_piece_data
	var type: int = next_piece_data["type"]
	var coords: Array = PIECE_SHAPES[type].map(func (v): return INIT_COORD+v)
	var r_flag: bool = next_piece_data["rotated"]
	var tetris_piece: TetrisPiece = TetrisPiece.new()
	tetris_piece.init(N_BLOCKS[type], type, coords, r_flag)
	next_piece_data = generate_piece_data()
	return tetris_piece
