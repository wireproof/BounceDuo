extends Area2D

@export var match_polygons: bool = true


func _ready():
	if match_polygons:
		$Polygon2D.polygon = $CollisionPolygon2D.polygon


func _on_body_entered(body):
	if body is Player:
		var ball: Player = body as Player
		ball.enter_water()

func _on_body_exited(body):
	if body is Player:
		var ball: Player = body as Player
		ball.exit_water()
