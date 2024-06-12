extends Control

@onready var color_rect = $ColorRect
@onready var vb_level_complete = $ColorRect/vb_LevelComplete
@onready var vb_game_over = $ColorRect/vb_GameOver

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.on_level_complete.connect(on_level_complete)
	SignalManager.on_game_over.connect(on_game_over)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if vb_level_complete.visible == true:
		if Input.is_action_just_pressed("jump") == true:
			GameManager.load_next_level_scene()

func show_hud() -> void:
	Engine.time_scale = 0
	color_rect.visible = true


func on_game_over() -> void:
	vb_game_over.visible = true
	show_hud()

func on_level_complete() -> void:
	vb_level_complete.visible = true
	show_hud()
