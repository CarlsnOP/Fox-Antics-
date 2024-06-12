extends Node2D

@onready var player_cam = $PlayerCam
@onready var player = $Player


func _ready():
	#Engine.time_scale = 1
	get_tree().paused = false


func _process(_delta):
	player_cam.position = player.position

