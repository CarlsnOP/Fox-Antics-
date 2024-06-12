extends Node2D

@onready var dash_timer = $DashTimer

func start_dash(dur) -> void:
	dash_timer.wait_time = dur
	dash_timer.start()
	
func is_dashing() -> bool:
	return !dash_timer.is_stopped()


func _on_dash_timer_timeout():
	pass # Replace with function body.
