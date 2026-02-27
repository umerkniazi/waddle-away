extends CanvasLayer

@onready var score_label := $ScoreLabel as Label
@onready var game_over_label := $GameOverLabel as Label
@onready var start_prompt := $StartPrompt as Label


func _ready() -> void:
	if game_over_label:
		game_over_label.hide()
	if start_prompt:
		start_prompt.hide()


func update_display(score: int, high_score: int) -> void:
	if score_label:
		score_label.text = "HI %05d  %05d" % [high_score, score]


func show_game_over() -> void:
	if game_over_label:
		game_over_label.text = "Game Over\nPress SPACE or ENTER to Restart"
		game_over_label.show()
	
	if start_prompt:
		start_prompt.hide()


func show_press_space() -> void:
	if start_prompt:
		start_prompt.text = "Press SPACE or ENTER to Start"
		start_prompt.show()
	
	if game_over_label:
		game_over_label.hide()


func hide_press_space() -> void:
	if start_prompt:
		start_prompt.hide()


func hide_game_over() -> void:
	if game_over_label:
		game_over_label.hide()
