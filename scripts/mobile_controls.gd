extends Control

signal jump_pressed
signal slide_started
signal slide_ended
signal screen_tapped

@export var show_touch_zones: bool = true

var right_touch_active: bool = false

@onready var left_zone := $LeftZone as ColorRect
@onready var right_zone := $RightZone as ColorRect


func _ready() -> void:
	if left_zone:
		left_zone.visible = show_touch_zones
		left_zone.color = Color(0, 1, 0, 0.3)
	if right_zone:
		right_zone.visible = show_touch_zones
		right_zone.color = Color(1, 0, 0, 0.3)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var screen_width: float = get_viewport_rect().size.x
		var touch_pos: float = event.position.x
		
		if event.pressed:
			screen_tapped.emit()
			
			if touch_pos < screen_width / 2:
				jump_pressed.emit()
			else:
				right_touch_active = true
				slide_started.emit()
		else:
			if touch_pos >= screen_width / 2 and right_touch_active:
				right_touch_active = false
				slide_ended.emit()
