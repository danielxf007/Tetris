extends Node

class_name LevelHandler

const MAX_LVL: int = 6
var next_level_cond: int
var completed_rows: int
var current_lvl: int

func init() -> void:
	next_level_cond = 2**3
	completed_rows = 0
	current_lvl = 1

func get_to_next_lvl(n_rows: int) -> bool:
	completed_rows+=n_rows
	if completed_rows >= next_level_cond:
		next_level_cond*=2
		completed_rows%=next_level_cond
		current_lvl+=1
		if current_lvl > MAX_LVL:
			current_lvl = MAX_LVL
		return true
	return false

