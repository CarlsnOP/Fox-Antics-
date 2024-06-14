extends Control


@onready var color_rect = $ColorRect
@onready var vb_level_complete = $ColorRect/vb_LevelComplete
@onready var vb_game_over = $ColorRect/vb_GameOver
@onready var hb_hearts = $MC/VBoxContainer/HB/HB_Hearts
@onready var score_label = $MC/VBoxContainer/HB/ScoreLabel
@onready var level_label = $MC/VBoxContainer/LevelLabel


var _hearts: Array

# Called when the node enters the scene tree for the first time.
func _ready():
	_hearts = hb_hearts.get_children()
	SignalManager.on_level_complete.connect(on_level_complete)
	SignalManager.on_game_over.connect(on_game_over)
	SignalManager.on_player_hit.connect(on_player_hit)
	SignalManager.on_score_updated.connect(on_score_updated)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if vb_level_complete.visible == true:
		if Input.is_action_just_pressed("next") == true:
			GameManager.load_next_level_scene()
	if vb_game_over.visible == true:
		if Input.is_action_just_pressed("next") == true:
			GameManager.load_main_scene()
	level_label.text = str("Level: ", GameManager.get_current_level(), "/3")

func show_hud() -> void:
	get_tree().paused = true
	color_rect.visible = true

func on_score_updated() -> void:
	score_label.text = str(ScoreManager.get_score()).lpad(5, "0")

func on_player_hit(lives: int) -> void:
	for life in range(_hearts.size()):
		_hearts[life].visible = lives > life

func on_game_over() -> void:
	vb_game_over.visible = true
	show_hud()

func on_level_complete() -> void:
	vb_level_complete.visible = true
	show_hud()
