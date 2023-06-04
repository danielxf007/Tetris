extends Node

class_name TetrisPiece

const ROTATIONS: Array = [
	[
		[Vector2i(), Vector2i(1,1), Vector2i(2,2), Vector2i(3,3)],
		[Vector2i(), Vector2i(-1,-1), Vector2i(-2,-2), Vector2i(-3,-3)]
	]
	,
	[
		[Vector2i(1,0), Vector2i(0,1), Vector2i(-1,0), Vector2i(-2,-1)],
		[Vector2i(0,-1), Vector2i(1,0), Vector2i(0,1), Vector2i(-1,2)],
		[Vector2i(-1,-1), Vector2i(0,-2), Vector2i(1,-1), Vector2i(2,0)],
		[Vector2i(0,2), Vector2i(-1,1), Vector2i(), Vector2i(1,-1)]
	],
	[
		[Vector2i(1,0), Vector2i(0,-1), Vector2i(-1, 0), Vector2i(-2, -1)],
		[Vector2i(-1,0), Vector2i(0,1), Vector2i(1, 0), Vector2i(2, 1)],
	],
	[
		[Vector2i(1,-1), Vector2i(), Vector2i(1,1), Vector2i(-1,-1)],
		[Vector2i(-1,0), Vector2i(0,1), Vector2i(1,0), Vector2i(-1,2)],
		[Vector2i(), Vector2i(1,-1), Vector2i(0,-2), Vector2i(2,0)],
		[Vector2i(0,1), Vector2i(-1,0), Vector2i(-2,1), Vector2i(0,-1)]
	],
	[
		[Vector2i(), Vector2i(), Vector2i(), Vector2i()]
	],
	[
		[Vector2i(), Vector2i(), Vector2i(), Vector2i()]
	]
]

var _n_blocks: int
var _block_coords: Array
var _type: int
var _rotation_vectors: Array
var _rotation: int

func init(n: int, type: int, coords: Array, rotated: bool) -> void:
	_n_blocks = n
	_type = type
	_block_coords = coords
	_rotation_vectors = ROTATIONS[type]
	_rotation = 0
	if rotated:
		for index in range(randi()%len(_rotation_vectors)+1):
			rotate()

func move_horizontal(units: int) -> void:
	var motion: Vector2i = Vector2i(units, 0)
	for index in range(_n_blocks):
		_block_coords[index]+=motion

func move_vertical(units: int) -> void:
	var motion: Vector2i = Vector2i(0, units)
	for index in range(_n_blocks):
		_block_coords[index]+=motion

func make_rotation(rotation_vectors: Array) -> void:
	for index in range(_n_blocks):
		_block_coords[index]+=rotation_vectors[index]

func rotate() -> void:
	for index in range(_n_blocks):
		_block_coords[index]+=_rotation_vectors[_rotation][index]
	_rotation = (_rotation+1)%len(_rotation_vectors)
