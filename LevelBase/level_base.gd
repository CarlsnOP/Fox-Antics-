extends Node2D

@onready var player_cam = $PlayerCam
@onready var player = $Player


func _ready():
	pass 


func _process(delta):
	pass


func _physics_process(delta):
	player_cam.position = player.position
