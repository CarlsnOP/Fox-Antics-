extends EnemyBase

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var jump_timer = $JumpTimer
@onready var censor = $Censor
@onready var censor_label = $CensorLabel


const JUMP_VELOCITY: Vector2 = Vector2(100, -300)
const JUMP_WAIT_RANGE: Vector2 = Vector2(2.5, 5.0)

var _jump: bool = false
var _seen_player: bool = false
var _frog_censored: bool = false

func _ready():
	super._ready()
	start_timer()
	SignalManager.censor_frog.connect(censor_frog)


func _physics_process(delta):
	super._physics_process(delta)
	
	if is_on_floor() == false:
		velocity.y += _gravity * delta
	else:
		velocity.x = 0
		animated_sprite_2d.play("idle")
	apply_jump()
	move_and_slide()
	flip_me()

func censor_frog() -> void:
	if _frog_censored == false:
		censor.visible = true
		censor_label.visible = true
		_frog_censored = true
	else:
		censor.visible = false
		censor_label.visible = false
		_frog_censored = false

func apply_jump() -> void:
	if is_on_floor() == false:
		return
	if _seen_player == false or _jump == false:
		return
	velocity = JUMP_VELOCITY
	if animated_sprite_2d.flip_h == false:
		velocity.x = velocity.x *-1
	
	_jump = false
	animated_sprite_2d.play("jump")
	start_timer()


func flip_me() -> void:
	if(_player_ref.global_position.x > global_position.x
		and animated_sprite_2d.flip_h == false):
			animated_sprite_2d.flip_h = true
	elif(_player_ref.global_position.x < global_position.x
		and animated_sprite_2d.flip_h == true):
			animated_sprite_2d.flip_h = false

func start_timer() -> void:
	jump_timer.wait_time = randf_range(JUMP_WAIT_RANGE.x, JUMP_WAIT_RANGE.y)
	jump_timer.start()


func _on_jump_timer_timeout():
	_jump = true
	
func _on_visible_on_screen_notifier_2d_screen_entered():
	_seen_player = true
