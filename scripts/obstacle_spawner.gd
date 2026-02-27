extends Node2D

signal hit_player

@export var obstacle_ice_scene: PackedScene
@export var fence_obstacle_scene: PackedScene
@export var ceiling_obstacle_scene: PackedScene
@export var spawn_distance := 400.0
@export var ground_y := -8.0
@export var ceiling_y := -22.0

const MIN_SPAWN_TIME := 1.2
const MAX_SPAWN_TIME := 2.5
const MIN_TIME_LIMIT := 0.6
const SPAWN_TIME_DECREASE := 0.015
const CEILING_PROBABILITY := 0.25
const FENCE_PROBABILITY := 0.12

var active := false
var current_speed := 250.0
var current_min_time := MIN_SPAWN_TIME
var current_max_time := MAX_SPAWN_TIME
var spawn_timer: Timer


func _ready() -> void:
	spawn_timer = Timer.new()
	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(_spawn_next)
	add_child(spawn_timer)


func start(speed: float) -> void:
	if active:
		return
	
	active = true
	current_speed = speed
	current_min_time = MIN_SPAWN_TIME
	current_max_time = MAX_SPAWN_TIME
	_schedule_spawn()


func stop() -> void:
	active = false
	if spawn_timer:
		spawn_timer.stop()


func set_speed(speed: float) -> void:
	current_speed = speed


func clear_all() -> void:
	for child in get_children():
		if child != spawn_timer and child is Area2D:
			child.queue_free()


func _schedule_spawn() -> void:
	if not active:
		return
	
	var wait_time := randf_range(current_min_time, current_max_time)
	spawn_timer.start(wait_time)
	
	current_min_time = max(MIN_TIME_LIMIT, current_min_time - SPAWN_TIME_DECREASE)
	current_max_time = max(MIN_TIME_LIMIT + 0.4, current_max_time - SPAWN_TIME_DECREASE)


func _spawn_next() -> void:
	if not active:
		return
	
	_create_obstacle()
	_schedule_spawn()


func _create_obstacle() -> void:
	var use_ceiling := randf() < CEILING_PROBABILITY and ceiling_obstacle_scene
	var scene: PackedScene
	var pos_y: float
	
	if use_ceiling:
		scene = ceiling_obstacle_scene
		pos_y = ceiling_y
	else:
		var use_fence := randf() < FENCE_PROBABILITY and fence_obstacle_scene
		
		if use_fence:
			scene = fence_obstacle_scene
		else:
			scene = obstacle_ice_scene
		
		pos_y = ground_y
	
	if not scene:
		return
	
	var obstacle := scene.instantiate() as Area2D
	if not obstacle:
		return
	
	obstacle.position = Vector2(spawn_distance, pos_y)
	add_child(obstacle)
	
	if obstacle.has_signal("body_entered"):
		obstacle.body_entered.connect(_on_obstacle_hit)


func _on_obstacle_hit(body: Node2D) -> void:
	if body.name == "Player":
		hit_player.emit()


func _process(delta: float) -> void:
	if not active:
		return
	
	for child in get_children():
		if child != spawn_timer and child is Node2D:
			child.position.x -= current_speed * delta
			
			if child.position.x < -100:
				child.queue_free()
