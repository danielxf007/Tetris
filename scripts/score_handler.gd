extends Node

class_name ScoreHandler

const MAX_SCORE: int = 10**9
var points_per_row: int
var score: int

func init() -> void:
	points_per_row = 10
	score = 0

func update_score(completed_rows: int) -> void:
	score+=(completed_rows*completed_rows*points_per_row)
	score%=MAX_SCORE

func update_points_per_row() -> void:
	points_per_row*=10
