extends Node

class_name TetrisMap

const MAP_DIMS: Vector2i = Vector2i(10, 24)
const CELL_DIMS: Vector2 = Vector2i(32, 32)
const OFFSET_ROW: int = 4
var textures: Dictionary = {
	"blue": load("res://assets/blue_block.jpg"),
	"green": load("res://assets/green_block.jpg"),
	"purple": load("res://assets/purple_block.jpg"),
	"red": load("res://assets/red_block.jpg"),
	"yellow": load("res://assets/yellow_block.jpg")}
var map: Array
var blocks: Array
var ghost_blocks: Array
var blocks_node: Node
var n_rows_cleared: int

func _ready():
	map = create_empty_map(MAP_DIMS)
	blocks_node = $Blocks
	blocks = Array()
	ghost_blocks = Array()
	n_rows_cleared = 0

func reset() -> void:
	clear_map(map, MAP_DIMS)
	clear_blocks_arr(blocks)
	clear_blocks_arr(ghost_blocks)
	n_rows_cleared = 0

# Util
func create_empty_row(size: int) -> Array:
	var row: Array = Array()
	for _i in range(size):
		row.append(null)
	return row

func create_empty_map(dims: Vector2i) -> Array:
	var _map: Array = []
	var row: Array
	for _i in range(dims.y):
		row = create_empty_row(dims.x)
		_map.append(row)
	return _map

func clear_map(_map: Array, dims: Vector2i) -> void:
	for i in range(dims.y):
		for j in range(dims.x):
			if _map[i][j] != null:
				_map[i][j].destroy()
			_map[i][j] = null

func clear_blocks_arr(arr: Array) -> void:
	for block in arr:
		block.destroy()
	arr.clear()

func map_coord_to_global_coord(coord: Vector2i) -> Vector2:
	var x: float = (CELL_DIMS.x/2)+(coord.x*CELL_DIMS.x)
	var y: float = (CELL_DIMS.y/2)+((coord.y-OFFSET_ROW)*CELL_DIMS.y)
	return Vector2(x, y)

func get_complete_row_indexes() -> Vector2i:
	var start_row: int = 0
	var end_row: int = 0
	for index in range(MAP_DIMS.y-1, OFFSET_ROW-1, -1):
		if not map[index].any(func(block): return block == null):
			start_row = index
			break
	for index in range(start_row-1, -1, -1):
		if map[index].any(func(block): return block == null):
			end_row = index
			break
	return Vector2i(start_row, end_row)

func clear_complete_rows(indexes: Vector2i) -> void:
	var m_cols: int = MAP_DIMS.x
	for i in range(indexes.x, indexes.y, -1):
		for j in range(m_cols):
			map[i][j].destroy()
			map[i][j] = null

func shift_map_down(indexes: Vector2i) -> void:
	var start_row: int = indexes.x
	var end_row: int = indexes.y
	var n: int = start_row-end_row
	var j: int
	for i in range(start_row, OFFSET_ROW-1, -1):
		j = i-n
		if j >= 0:
			map[i] = map[j]
			map[j] = create_empty_row(MAP_DIMS.x)
		else:
			map[i] = create_empty_row(MAP_DIMS.x)
 
# Tetris State validation
func check_outside_bounds(tetris_piece: TetrisPiece) -> bool:
	var map_coords: Array = tetris_piece._block_coords
	var out: bool
	for coord in map_coords:
		out = coord.x < 0 or coord.x >= MAP_DIMS.x
		out = out or coord.y >= MAP_DIMS.y
		if out:
			return true
	return false

func check_block_collision(tetris_piece: TetrisPiece) -> bool:
	var map_coords: Array = tetris_piece._block_coords
	for coord in map_coords:
		if check_outside_bounds(tetris_piece) or map[coord.y][coord.x] != null:
			return true
	return false

func has_blocks_in_hidden_zone() -> bool:
	for i in range(OFFSET_ROW):
		if map[i].any(func (b): return b != null):
			return true
	return false

# Update
func update_moving_blocks_pos(tetris_piece: TetrisPiece) -> void:
	var coords: Array = tetris_piece._block_coords
	var pos: Vector2
	for index in range(tetris_piece._n_blocks):
		pos = map_coord_to_global_coord(coords[index])
		blocks[index].global_position = pos

func update_ghost_blocks_pos(ghost_piece: TetrisPiece) -> void:
	var coords: Array = ghost_piece._block_coords
	var pos: Vector2
	if len(ghost_blocks):
		for index in range(ghost_piece._n_blocks):
			pos = map_coord_to_global_coord(coords[index])
			ghost_blocks[index].global_position = pos

func update_static_blocks_pos() -> void:
	var m_cols: int = MAP_DIMS.x
	var pos: Vector2
	for i in range(MAP_DIMS.y-1, OFFSET_ROW-1, -1):
		for j in range(m_cols):
			if map[i][j] != null:
				pos = map_coord_to_global_coord(Vector2i(j, i))
				map[i][j].global_position = pos

func fill_blocks(tetris_piece: TetrisPiece) -> void:
	var coords: Array = tetris_piece._block_coords
	var coord: Vector2i
	for index in range(tetris_piece._n_blocks):
		coord = coords[index]
		map[coord.y][coord.x] = blocks[index]  
	
func update_map(tetris_piece: TetrisPiece) -> void:
	var clear_indexes: Vector2i
	clear_blocks_arr(ghost_blocks)
	fill_blocks(tetris_piece)
	clear_indexes = get_complete_row_indexes()
	clear_complete_rows(clear_indexes)
	shift_map_down(clear_indexes)
	update_static_blocks_pos()
	n_rows_cleared = clear_indexes.x-clear_indexes.y

# Collision Processing
func create_block(color: String) -> Block:
	var block: Block = Block.new()
	block.scale = Vector2(0.5, 0.5)
	block.texture = textures[color]
	return block

func create_ghost_block(color: String) -> GhostBlock:
	var block: GhostBlock = GhostBlock.new()
	block.scale = Vector2(0.5, 0.5)
	block.texture = textures[color]
	return block

func create_blocks(tetris_piece: TetrisPiece, color: String) -> void:
	var coords: Array = tetris_piece._block_coords
	var block: Block
	blocks.clear()
	for coord in coords:
		block = create_block(color)
		blocks.append(block)
		block.hide()
		blocks_node.add_child(block)
		block.global_position = map_coord_to_global_coord(coord)
		block.show()

func create_ghost_blocks(tetris_piece: TetrisPiece, color: String) -> void:
	var coords: Array = tetris_piece._block_coords
	var block: GhostBlock
	ghost_blocks.clear()
	for coord in coords:
		block = create_ghost_block(color)
		ghost_blocks.append(block)
		block.hide()
		blocks_node.add_child(block)
		block.global_position = map_coord_to_global_coord(coord)
		block.show()

func create_blocks_from(tetris_piece: TetrisPiece, color: String) -> void:
	create_blocks(tetris_piece, color)
	create_ghost_blocks(tetris_piece, color)
