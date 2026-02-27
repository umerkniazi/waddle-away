extends CharacterBody2D

const JUMP_FORCE := -310.0
const GRAVITY := 1200.0
const GROUND_POSITION := -8.0

var is_alive := true
var is_ducking := false
var mobile_ducking := false

@onready var sprite := $AnimatedSprite2D
@onready var collision := $CollisionShape2D
@onready var jump_sound := $JumpSound
@onready var hurt_sound := $HurtSound

var normal_collision_height: float
var normal_collision_offset: float


func _ready() -> void:
	if collision and collision.shape:
		normal_collision_height = collision.shape.size.y
		normal_collision_offset = collision.position.y


func reset_state() -> void:
	is_alive = false
	is_ducking = false
	velocity = Vector2.ZERO
	position.y = GROUND_POSITION
	_restore_collision()
	if sprite:
		sprite.play("idle")


func start_running() -> void:
	is_alive = true
	if sprite:
		sprite.play("run")


func die() -> void:
	is_alive = false
	velocity = Vector2.ZERO
	if sprite:
		sprite.play("hurt")
	if hurt_sound:
		hurt_sound.play()


func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	
	_apply_gravity(delta)
	_handle_input()
	_update_animation()
	
	move_and_slide()


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta


func _handle_input() -> void:
	if not is_alive:
		return
	
	if is_on_floor():
		if Input.is_action_just_pressed("jump") and not is_ducking:
			_perform_jump()
		
		if not mobile_ducking:
			if Input.is_action_pressed("ui_down"):
				_duck()
			else:
				_stand()
	else:
		if not mobile_ducking:
			_stand()


func mobile_jump() -> void:
	if is_alive and is_on_floor() and not is_ducking:
		_perform_jump()


func mobile_slide_start() -> void:
	if is_alive and is_on_floor():
		mobile_ducking = true
		_duck()


func mobile_slide_end() -> void:
	mobile_ducking = false
	_stand()


func _perform_jump() -> void:
	velocity.y = JUMP_FORCE
	if jump_sound:
		jump_sound.play()


func _update_animation() -> void:
	if not sprite or not is_alive:
		return
	
	if not is_on_floor():
		sprite.play("jump")
	elif is_ducking:
		sprite.play("slide")
	else:
		sprite.play("run")


func _duck() -> void:
	if is_ducking:
		return
	
	is_ducking = true
	
	if collision and collision.shape:
		collision.shape.size.y = normal_collision_height * 0.5
		collision.position.y = normal_collision_offset + normal_collision_height * 0.25


func _stand() -> void:
	if not is_ducking:
		return
	
	is_ducking = false
	_restore_collision()


func _restore_collision() -> void:
	if collision and collision.shape:
		collision.shape.size.y = normal_collision_height
		collision.position.y = normal_collision_offset
