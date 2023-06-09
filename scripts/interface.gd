extends Control

const N_BLOCKS:Array = [4, 4, 4, 4, 4, 4, 4, 1]
const CELL_DIMS: Vector2i = Vector2i(32, 32)
const INIT_POINTS: Array = [
	Vector2i(400,256), # Bar
	Vector2i(416,240), # L
	Vector2i(480,240), # L Flip,
	Vector2i(432,240), # Square
	Vector2i(480,240), # Z
	Vector2i(416,240), # Z flip
	Vector2i(448,272), # Triangle
	Vector2i(448,256) # Block
]
@export var GAME_NODE: Node
var blocks: Array
var interface_blocks: Array
var textures: Dictionary = {
	"blue": load("res://assets/blue_block.jpg"),
	"green": load("res://assets/green_block.jpg"),
	"purple": load("res://assets/purple_block.jpg"),
	"red": load("res://assets/red_block.jpg"),
	"yellow": load("res://assets/yellow_block.jpg")}

func _ready():
	blocks = Array()
	var sprite: Sprite2D
	var row: Array
	for i in range(len(N_BLOCKS)):
		row = Array()
		for j in range(N_BLOCKS[i]):
			sprite = Sprite2D.new()
			sprite.scale = Vector2(0.5, 0.5)
			$Blocks.add_child(sprite)
			row.append(sprite)
		blocks.append(row)

func update_score_number(new_score: int) -> void:
	var score: String = str(new_score)
	score = score.lpad(10, "0")
	$ScoreNumbersL.text = score

func hide_interface_blocks() -> void:
	for block in interface_blocks:
		block.hide()

func show_interface_blocks() -> void:
	for block in interface_blocks:
		block.show()

func update_next_piece(piece: TetrisPiece, color: String) -> void:
	hide_interface_blocks()
	var type: int = piece._type
	interface_blocks = blocks[type]
	var vectors: Array = piece._block_coords.map(
		func (coord): return coord-piece._block_coords[0])
	var init_point: Vector2i = INIT_POINTS[type]
	for i in range(len(interface_blocks)):
		interface_blocks[i].texture = textures[color]
		interface_blocks[i].global_position = init_point+(vectors[i]*CELL_DIMS)
	show_interface_blocks()


func _on_play_button_down():
	GAME_NODE.play()

func _on_pause_button_down():
	GAME_NODE.pause()

func _on_reset_button_down():
	GAME_NODE.reset()

func _on_game_got_next_piece(piece, color):
	update_next_piece(piece, color)

func _on_game_score_updated(score):
	update_score_number(score)
