extends Node2D

@onready var player_cam = $PlayerCam
@onready var player = $Player


func _ready():
	get_tree().paused = false


func _process(_delta):
	player_cam.position = player.position

