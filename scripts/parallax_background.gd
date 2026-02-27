extends Node2D

@export var scroll_speed: float = -50.0
@export var sprite_width: float = 288.0

var is_active: bool = true

@onready var sky_layer := $SkyLayer as Parallax2D
@onready var mountain_layer := $MountainLayer as Parallax2D
@onready var foreground_layer := $ForegroundLayer as Parallax2D


func _ready() -> void:
	if sky_layer:
		sky_layer.repeat_size = Vector2(sprite_width, 0)
		sky_layer.repeat_times = 5
	if mountain_layer:
		mountain_layer.repeat_size = Vector2(sprite_width, 0)
		mountain_layer.repeat_times = 5
	if foreground_layer:
		foreground_layer.repeat_size = Vector2(sprite_width, 0)
		foreground_layer.repeat_times = 5


func _process(_delta: float) -> void:
	if not is_active:
		return
	
	if sky_layer:
		sky_layer.autoscroll = Vector2(scroll_speed * 0.2, 0)
	if mountain_layer:
		mountain_layer.autoscroll = Vector2(scroll_speed * 0.5, 0)
	if foreground_layer:
		foreground_layer.autoscroll = Vector2(scroll_speed * 0.8, 0)


func stop() -> void:
	is_active = false
	if sky_layer:
		sky_layer.autoscroll = Vector2.ZERO
	if mountain_layer:
		mountain_layer.autoscroll = Vector2.ZERO
	if foreground_layer:
		foreground_layer.autoscroll = Vector2.ZERO


func start() -> void:
	is_active = true
