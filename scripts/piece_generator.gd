extends Node

class_name PieceGenerator

const PIECE_TYPES: int = 6
const N_BLOCKS:Array = [4, 4, 4, 4, 4, 4, 4, 1]
const COLORS: Array = ["blue", "green", "purple", "red", "yellow"]
const INIT_COORDS: Array = [
Vector2i(3, 1), # Bar
Vector2i(3, 0), # L
Vector2i(6, 0), # L flip
Vector2i(4, 0), # Square
Vector2i(6, 0), # Z
Vector2i(3, 0), # Z flip
Vector2i(4, 0), # Triangle
Vector2i(4, 3)] # Block
const PIECE_SHAPES: Array = [
	[Vector2i(), Vector2i(1,0), Vector2i(2,0), Vector2i(3,0)], # Bar
	[Vector2i(), Vector2i(0,1), Vector2i(1,1), Vector2i(2,1)], # L
	[Vector2i(), Vector2i(0,1), Vector2i(-1,1), Vector2i(-2,1)], # L flip
	[Vector2i(), Vector2i(1, 0), Vector2i(1,1), Vector2i(0,1)], # Square
	[Vector2i(), Vector2i(-1, 0), Vector2i(-1,1), Vector2i(-2,1)], # Z
	[Vector2i(), Vector2i(1, 0), Vector2i(1,1), Vector2i(2,1)], # Z flip
	[Vector2i(), Vector2i(-1, 1), Vector2i(0,1), Vector2i(1,1)], # Triangle
	[Vector2i()] # Block
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
	return piece_data

func generate_piece() -> TetrisPiece:
	current_piece_data = next_piece_data
	var type: int = next_piece_data["type"]
	var coords: Array = PIECE_SHAPES[type].map(
		func (v): return INIT_COORDS[type]+v)
	var tetris_piece: TetrisPiece = TetrisPiece.new()
	tetris_piece.init(N_BLOCKS[type], type, coords)
	next_piece_data = generate_piece_data()
	return tetris_piece
