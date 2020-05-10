extends Node

export (PackedScene) var ShellScene

func _ready():
	$Tank.bounds = Rect2(Vector2(0, 0), get_viewport().size)

func _process(delta):
	var moveX = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var moveY = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	$Tank.move(
		delta,
		$Tank.MoveX.Left if moveX < 0 else $Tank.MoveX.Right if moveX > 0 else $Tank.MoveX.Stop,
		$Tank.MoveY.Forward if moveY < 0 else $Tank.MoveY.Stop if moveY > 0 else $Tank.MoveY.SlowForward
	)
	
	var turn = Input.get_action_strength("turn_cw") - Input.get_action_strength("turn_ccw")
	$Tank.turnTurret(
		delta,
		$Tank.TurnDir.CCW if turn < 0 else $Tank.TurnDir.CW if turn > 0 else $Tank.TurnDir.Stop
	)

func _input(event):
	if event.is_action_pressed("fire_cannon"):
		fireCannon()
		$AutoFireTimer.start(.2)
	elif event.is_action_released("fire_cannon"):
		$AutoFireTimer.stop()

func _on_AutoFireTimer_timeout():
	fireCannon()

func fireCannon():
	var shell = ShellScene.instance()
	shell.velocity = Vector2(0, -1000).rotated($Tank/Turret.rotation)
	shell.position = $Tank/Turret/BarrelEnd.global_position
	add_child(shell)
