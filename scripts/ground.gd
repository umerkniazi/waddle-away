extends Node2D

@export var scroll_speed := 180.0

var tilemaps: Array[TileMapLayer] = []
var tilemap_width: float
var total_width: float
var active := false


func _ready() -> void:
	for child in get_children():
		if child is TileMapLayer:
			tilemaps.append(child)
	
	if tilemaps.is_empty():
		return
	
	var used_rect := tilemaps[0].get_used_rect()
	var tile_size := tilemaps[0].tile_set.tile_size
	tilemap_width = used_rect.size.x * tile_size.x
	total_width = tilemap_width * tilemaps.size()
	
	for i in tilemaps.size():
		tilemaps[i].position.x = i * tilemap_width


func start() -> void:
	active = true


func stop() -> void:
	active = false


func set_speed(speed: float) -> void:
	scroll_speed = speed


func _process(delta: float) -> void:
	if not active:
		return
	
	for tilemap in tilemaps:
		tilemap.position.x -= scroll_speed * delta
		
		if tilemap.position.x < -tilemap_width:
			tilemap.position.x += total_width
