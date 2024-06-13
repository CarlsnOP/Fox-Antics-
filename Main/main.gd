extends CanvasLayer


@onready var label_high_score = $VB/LabelHighScore

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().paused = false
	label_high_score.text = "HighScore: " + str(ScoreManager.get_high_score())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("next") == true:
		GameManager.load_next_level_scene()
