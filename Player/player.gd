extends CharacterBody2D


class_name Player

@onready var duck_timer = $Timers/DuckTimer
@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var debug_label = $DebugLabel
@onready var sound_player = $SoundPlayer
@onready var shooter = $Shooter
@onready var animation_player_invincible = $AnimationPlayerInvincible
@onready var invincible_timer = $Timers/InvincibleTimer
@onready var hurt_timer = $Timers/HurtTimer
@onready var hit_box = $HitBox
@onready var dash_timer = $Timers/DashTimer
@onready var dash_cd_timer = $Timers/DashCDTimer
@onready var dash_player = $DashPlayer
@onready var effect_player = $EffectPlayer
@onready var gun = $Gun


const GRAVITY: float = 690.0
const RUN_SPEED: float = 120.0
const MAX_FALL: float = 400.0
const JUMP_VELOCITY: float = -300.0
const DOUBLE_JUMP_VELOCITY: float = -250.0
const _HURT_JUMP_VELOCITY: Vector2 = Vector2(0, -130.0)
const FALLEN_OFF: float = 100.0
const DASH_SPEED: float = 700.0
const DASH_LENGTH: float = 0.1
const DASH_HEIGHT: float = -700

enum PLAYER_STATE { IDLE, RUN, JUMP, FALL, HURT, DASH }

var _state: PLAYER_STATE = PLAYER_STATE.IDLE
var _invincible: bool = false
var _lives: int = 5
var _speed: float = 80.0
var _dash_cd_time: float = 0.5
var _dash_on_cd: bool = false
var _can_double_jump: bool = false
var _gun_picked_up: bool = false


func _ready():
	gun.visible = false
	SignalManager.on_player_hit.emit(_lives)
	SignalManager.gatling_gun_pickup.connect(gatling_gun_pickup)
	if _gun_picked_up == true:
		gatling_gun_pickup()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	fallen_off()
	
	if is_on_floor() == false:
		velocity.y += GRAVITY * delta	
	
	get_input()
	move_and_slide()
	calculate_states()
	update_debug_label()
	
	if Input.is_action_just_pressed("shoot") == true:
		shoot()
	
	if Input.is_action_just_pressed("frog") == true:
		SignalManager.censor_frog.emit()

func update_debug_label() -> void:
	debug_label.text = "floor: %s inv:%s\n%s\n%.0f,%.0f" % [
		is_on_floor(), _invincible,
		PLAYER_STATE.keys()[_state],
		velocity.x, velocity.y
	]

func gatling_gun_pickup() -> void:
	gun.visible = true
	_gun_picked_up = true

func fallen_off() -> void:
	if global_position.y < FALLEN_OFF:
		return
	
	_lives = 1
	reduce_lives()

func shoot() -> void:
	if sprite_2d.flip_h == true:
		shooter.shoot(Vector2.LEFT)
	else:
		shooter.shoot(Vector2.RIGHT)

func dash() -> void:
	_speed = DASH_SPEED
	SoundManager.play_clip(effect_player, SoundManager.SOUND_DASH)
	dash_timer.start(DASH_LENGTH)

func get_input() -> void:
	if _state == PLAYER_STATE.HURT:
		return
		
	velocity.x = 0
	
	if Input.is_action_pressed("left") == true:
		velocity.x = -_speed
		sprite_2d.flip_h = true
		gun.flip_h = false
		gun.position.x = -10
	elif Input.is_action_pressed("right") == true:
		velocity.x = _speed
		sprite_2d.flip_h = false
		gun.flip_h = true
		gun.position.x = 10
	
	if Input.is_action_just_pressed("jump") == true and is_on_floor() == true:
		velocity.y = JUMP_VELOCITY
		SoundManager.play_clip(sound_player, SoundManager.SOUND_JUMP)
		_can_double_jump = true
	
	if Input.is_action_just_pressed("jump") == true	and is_on_floor() == false and _can_double_jump == true:
		velocity.y = DOUBLE_JUMP_VELOCITY
		_can_double_jump = false
		
	velocity.y = clampf(velocity.y, JUMP_VELOCITY, MAX_FALL)

	if Input.is_action_pressed("duck") == true:
		fall_through()
 
func fall_through() -> void:
	if is_on_floor() == true:
		set_collision_mask_value(7, false)
		dash_player.play("duck")
		duck_timer.start()

func calculate_states() -> void:
	if _state == PLAYER_STATE.HURT:
		return
		
	if Input.is_action_just_pressed("dash") and _dash_on_cd == false and velocity.x != 0:
		set_state(PLAYER_STATE.DASH)
		dash()
	
	if _state != PLAYER_STATE.DASH:
		if is_on_floor() == true:
			if velocity.x == 0:
				set_state(PLAYER_STATE.IDLE)
			else:
				set_state(PLAYER_STATE.RUN)
		else:
			if velocity.y > 0:
				set_state(PLAYER_STATE.FALL)
			else:
				set_state(PLAYER_STATE.JUMP)

func set_state(new_state: PLAYER_STATE) -> void:
	if new_state == _state:
		return
		
	if _state == PLAYER_STATE.FALL:
		if new_state == PLAYER_STATE.IDLE or new_state == PLAYER_STATE.RUN:
			SoundManager.play_clip(effect_player, SoundManager.SOUND_LAND)
	_state = new_state
	
	match _state:
		PLAYER_STATE.IDLE:
			animation_player.play("idle")
		PLAYER_STATE.RUN:
			animation_player.play("run")
		PLAYER_STATE.JUMP:
			animation_player.play("jump")
		PLAYER_STATE.FALL:
			animation_player.play("fall")
		PLAYER_STATE.HURT:
			apply_hurt_jump()
		PLAYER_STATE.DASH:
			dash_player.play("dash")

func apply_hurt_jump() -> void:
	animation_player.play("hurt")
	velocity = _HURT_JUMP_VELOCITY
	hurt_timer.start()

func go_invincible() -> void:
	_invincible = true
	animation_player_invincible.play("invincible")
	invincible_timer.start()

func reduce_lives() -> bool:
	_lives -= 1
	SignalManager.on_player_hit.emit(_lives)
	
	if _lives <= 0:
		SignalManager.on_game_over.emit()
		set_physics_process(false)
		return false
	return true

func apply_hit() -> void:
	if _invincible == true:
		return
	
	if reduce_lives() == false:
		return
		
	go_invincible()
	set_state(PLAYER_STATE.HURT)
	apply_hurt_jump()
	SoundManager.play_clip(sound_player, SoundManager.SOUND_DAMAGE)

func retake_damage() -> void:
	for area in hit_box.get_overlapping_areas():
		if area.is_in_group("Dangers") == true:
			apply_hit()
			break
	return

func _on_hit_box_area_entered(_area):
	apply_hit()

func _on_invincible_timer_timeout():
	_invincible = false
	animation_player_invincible.stop()
	retake_damage()

func _on_hurt_timer_timeout():
	set_state(PLAYER_STATE.IDLE)

func _on_dash_timer_timeout():
	set_state(PLAYER_STATE.IDLE)
	_speed = RUN_SPEED
	dash_cd_timer.start(_dash_cd_time)
	_dash_on_cd = true

func _on_dash_cd_timer_timeout():
	_dash_on_cd = false

func _on_duck_timer_timeout():
	set_collision_mask_value(7, true)
