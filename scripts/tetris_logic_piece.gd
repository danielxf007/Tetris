extends Node

class_name TetrisPiece

const ROTATIONS: Array = [
	[
		[Vector2i(2,2), Vector2i(1,1), Vector2i(), Vector2i(-1,-1)],
		[Vector2i(1,-1), Vector2i(), Vector2i(-1,1), Vector2i(-2,2)],
		[Vector2i(-2,-2), Vector2i(-1,-1), Vector2i(), Vector2i(1,1)],
		[Vector2i(-1,1), Vector2i(), Vector2i(1,-1), Vector2i(2,-2)]
	], # Bar
	[
		[Vector2i(2,0), Vector2i(1,-1), Vector2i(), Vector2i(-1,1)],
		[Vector2i(0,2), Vector2i(1,1), Vector2i(), Vector2i(-1,-1)],
		[Vector2i(-2,0), Vector2i(-1,1), Vector2i(), Vector2i(1,-1)],
		[Vector2i(0,-2), Vector2i(-1,-1), Vector2i(), Vector2i(1,1)]
	], # L 
	[
		[Vector2i(0,2), Vector2i(-1,1), Vector2i(), Vector2i(1,-1)],
		[Vector2i(-2,0), Vector2i(-1,-1), Vector2i(), Vector2i(1,1)],
		[Vector2i(0,-2), Vector2i(1,-1), Vector2i(), Vector2i(-1,1)],
		[Vector2i(2,0), Vector2i(1,1), Vector2i(), Vector2i(-1,-1)]
	], # L Flip,
	[
		[Vector2i(), Vector2i(), Vector2i(), Vector2i()]
	], # Square
	[
		[Vector2i(0,2), Vector2i(1,1), Vector2i(), Vector2i(1,-1)],
		[Vector2i(-2,0), Vector2i(-1,1), Vector2i(), Vector2i(1,1)],
		[Vector2i(0,-2), Vector2i(-1,-1), Vector2i(), Vector2i(-1,1)],
		[Vector2i(2,0), Vector2i(1,-1), Vector2i(), Vector2i(-1,-1)],
	], # Z
	[
		[Vector2i(2,0), Vector2i(1,1), Vector2i(), Vector2i(-1,1)],
		[Vector2i(0,2), Vector2i(-1,1), Vector2i(), Vector2i(-1,-1)],
		[Vector2i(-2,0), Vector2i(-1,-1), Vector2i(), Vector2i(1,-1)],
		[Vector2i(0,-2), Vector2i(1,-1), Vector2i(), Vector2i(1,1)],
	], # Z flip
	[
		[Vector2i(1,1), Vector2i(1,-1), Vector2i(), Vector2i(-1,1)],
		[Vector2i(-1,1), Vector2i(1,1), Vector2i(), Vector2i(-1,-1)],
		[Vector2i(-1,-1), Vector2i(-1,1), Vector2i(), Vector2i(1,-1)],
		[Vector2i(1,-1), Vector2i(-1,-1), Vector2i(), Vector2i(1,1)]
	], # Triangle
	[
		[Vector2i(), Vector2i(), Vector2i(), Vector2i()]
	] # Block
]

var _n_blocks: int
var _block_coords: Array
var _type: int
var _rotation_vectors: Array
var _rotation: int
var last_state: Dictionary

func init(n: int, type: int, coords: Array) -> void:
	_n_blocks = n
	_type = type
	_block_coords = coords
	_rotation_vectors = ROTATIONS[type]
	_rotation = 0
	last_state = {"coords": coords.duplicate(), "rotation": _rotation}

func save_state() -> void:
	last_state["coords"] = _block_coords.duplicate()
	last_state["rotation"] = _rotation

func move_horizontal(units: int) -> void:
	save_state()
	var motion: Vector2i = Vector2i(units, 0)
	for index in range(_n_blocks):
		_block_coords[index]+=motion

func move_vertical(units: int) -> void:
	save_state()
	var motion: Vector2i = Vector2i(0, units)
	for index in range(_n_blocks):
		_block_coords[index]+=motion

func rotate() -> void:
	save_state()
	for index in range(_n_blocks):
		_block_coords[index]+=_rotation_vectors[_rotation][index]
	_rotation = (_rotation+1)%len(_rotation_vectors)

func revert() -> void:
	_block_coords = last_state["coords"].duplicate()
	_rotation = last_state["rotation"]
