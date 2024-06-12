extends PathFollow2D


@export var speed: float = 0.2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	progress_ratio = progress_ratio + delta * speed
