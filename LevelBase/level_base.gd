extends Node2D

@onready var player_cam = $PlayerCam
@onready var player = $Player
@onready var hud = $CanvasLayer/HUD
@onready var color_rect = $CanvasLayer/HUD/ColorRect
@onready var vb_pause_menu = $CanvasLayer/HUD/ColorRect/vb_PauseMenu
@onready var censor = $Controls/Censor
@onready var edita_filter_2 = $Controls/EditaFilter2


var _frog_censored: bool = false


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().paused = false
	SignalManager.censor_frog.connect(censor_frog)

func _process(_delta):
	player_cam.position = player.position
	if Input.is_action_just_pressed("menu"):
		pause_menu()
	

func censor_frog() -> void:
	if _frog_censored == false:
		censor.visible = true
		edita_filter_2.visible = true
		_frog_censored = true
	else:
		censor.visible = false
		edita_filter_2.visible = false
		_frog_censored = false

func pause_menu() -> void:
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		color_rect.show()
		vb_pause_menu.show()

func _on_button_pressed():
	get_tree().paused = false
	color_rect.hide()
	vb_pause_menu.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_button_2_pressed():
	GameManager.load_main_scene()

func _on_button_3_pressed():
	get_tree().quit()
