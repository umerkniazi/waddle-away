extends Node2D

enum GameState { WAITING, PLAYING, DEAD }

const SPEED_INCREMENT := 0.0005
const INITIAL_SPEED := 180.0
const MAX_SPEED := 600.0
const SCORE_PER_SECOND := 10.0
const SAVE_FILE := "user://highscore.dat"

var current_state := GameState.WAITING
var game_speed := INITIAL_SPEED
var distance := 0.0
var high_score := 0

@onready var player := $Player
@onready var spawner := $ObstacleSpawner
@onready var ui := $UI
@onready var ground := $Ground
@onready var parallax_bg := $ParallaxBG
@onready var mobile_controls := $UI/MobileControls


func _ready() -> void:
	load_high_score()
	spawner.hit_player.connect(_on_hit_player)
	
	if mobile_controls:
		mobile_controls.jump_pressed.connect(player.mobile_jump)
		mobile_controls.slide_started.connect(player.mobile_slide_start)
		mobile_controls.slide_ended.connect(player.mobile_slide_end)
		mobile_controls.screen_tapped.connect(_on_mobile_screen_tap)
	
	_reset_to_start()


func _reset_to_start() -> void:
	current_state = GameState.WAITING
	game_speed = INITIAL_SPEED
	distance = 0.0
	
	player.reset_state()
	spawner.clear_all()
	
	ui.update_display(0, high_score)
	ui.show_press_space()
	ui.hide_game_over()


func _physics_process(delta: float) -> void:
	if current_state == GameState.PLAYING:
		distance += delta * game_speed
		game_speed = min(game_speed + SPEED_INCREMENT * delta * 60.0, MAX_SPEED)
		
		var score := int(distance / game_speed * SCORE_PER_SECOND)
		if score > high_score:
			high_score = score
		
		ui.update_display(score, high_score)
		spawner.set_speed(game_speed)
		if ground:
			ground.set_speed(game_speed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("jump"):
		if current_state == GameState.WAITING:
			_start_game()
		elif current_state == GameState.DEAD:
			_reset_to_start()
			_start_game()


func _on_mobile_screen_tap() -> void:
	if current_state == GameState.WAITING:
		_start_game()
	elif current_state == GameState.DEAD:
		_reset_to_start()
		_start_game()


func _start_game() -> void:
	current_state = GameState.PLAYING
	player.start_running()
	spawner.start(game_speed)
	if ground:
		ground.start()
	if parallax_bg:
		parallax_bg.start()
	ui.hide_press_space()


func _on_hit_player() -> void:
	if current_state != GameState.PLAYING:
		return
	
	current_state = GameState.DEAD
	
	spawner.stop()
	if ground:
		ground.stop()
	if parallax_bg:
		parallax_bg.stop()
	player.die()
	
	var final_score := int(distance / INITIAL_SPEED * SCORE_PER_SECOND)
	if final_score > high_score:
		high_score = final_score
		save_high_score()
	
	ui.show_game_over()


func load_high_score() -> void:
	if not FileAccess.file_exists(SAVE_FILE):
		high_score = 0
		return
	
	var file := FileAccess.open(SAVE_FILE, FileAccess.READ)
	if file:
		high_score = file.get_var()
		file.close()


func save_high_score() -> void:
	var file := FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_var(high_score)
		file.close()
