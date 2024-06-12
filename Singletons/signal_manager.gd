extends Node

signal on_enemy_hit(points: int, enemy_position: Vector2)
signal on_pickup_hit(points: int)
signal on_boss_killed(points: int)
signal on_player_hit(lives: int)
signal on_level_complete
signal on_game_over
