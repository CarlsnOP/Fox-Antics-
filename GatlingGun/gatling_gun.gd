extends Area2D

func _on_area_entered(area):
	SignalManager.gatling_gun_pickup.emit()
	print("haps")
