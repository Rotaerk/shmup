extends Area2D

export (Vector2) var velocity = Vector2(0, -100)

func _ready():
	rotation = Vector2(0, -1).angle_to(velocity)

func _process(delta):
	position += delta * velocity

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
