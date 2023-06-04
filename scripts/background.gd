extends Sprite2D

const MAP_DIMS: Vector2i = Vector2i(10, 24)
const CELL_DIMS: Vector2 = Vector2i(32, 32)
const OFFSET_ROW: int = 4

func _draw():
	var pos: Vector2 = -global_position
	for _i in range(OFFSET_ROW, MAP_DIMS.y):
		pos.x = -global_position.x
		for _j in range(MAP_DIMS.x):
			draw_rect(Rect2(pos, CELL_DIMS), Color.GRAY, false, 1.5)
			pos.x+=(CELL_DIMS.x)
		pos.y+=(CELL_DIMS.y)
