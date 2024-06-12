extends Node2D

@onready var player_cam = $PlayerCam
@onready var player = $Player


func _ready():
	Engine.time_scale = 1


func _process(delta):
	player_cam.position = player.position

