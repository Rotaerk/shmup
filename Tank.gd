extends Node2D

export (Rect2) var bounds = Rect2(100, 100, 400, 400)
export (float) var baseMoveSpeed = 200
export (float) var maxTurnAngle = PI / 6
export (float) var turnSpeed = PI / 6

const sqrt3 = sqrt(3)

enum MoveX { Left, Stop, Right }
enum MoveY { Forward, SlowForward, Stop } # Visually these are forward, stop, and backward, respectively

func move(timeDelta: float, moveX, moveY):
	# Account for bounds now, since movement affects more than just position.
	# (If it only affected position, we could depend solely on a clamp at the end.)
	if (moveX == MoveX.Right and position.x == bounds.end.x) or (moveX == MoveX.Left and position.x == bounds.position.x):
		moveX = MoveX.Stop
	if (moveY == MoveY.Stop and position.y == bounds.end.y) or (moveY == MoveY.Forward and position.y == bounds.position.y):
		moveY = MoveY.SlowForward
	
	var velocity: Vector2
	if moveX == MoveX.Stop:
		match moveY:
			# don't move
			MoveY.Stop: velocity = Vector2(0, 0)
			# move forward at base speed
			MoveY.SlowForward: velocity = Vector2(0, -1)
			# move forward at double speed
			MoveY.Forward: velocity = Vector2(0, -2)
	else:
		match moveY:
			MoveY.Stop:
				# if down-left/right, move left/right at double speed.
				velocity = Vector2(moveXMultiplier(moveX) * 2, 0)
			MoveY.SlowForward:
				# if left/right, move forward-and-left/right at double speed
				# such that the forward component is base speed.
				# sqrt(3)^2 + 1^2 == 2^2
				velocity = Vector2(moveXMultiplier(moveX) * sqrt3, -1)
			MoveY.Forward:
				# if up-left/right, move forward-and-left/right at double speed
				# such that the left/right component is base speed.
				velocity = Vector2(moveXMultiplier(moveX), -sqrt3)
	
	# turn to face direction of travel
	if velocity != Vector2(0,0):
		$Hull.rotation = Vector2(0,-1).angle_to(velocity);
	
	# The reference frame is moving downward at base speed
	var screenVelocity = velocity + Vector2(0, 1)

	position += timeDelta * baseMoveSpeed * screenVelocity
	
	position.x = clamp(position.x, bounds.position.x, bounds.end.x)
	position.y = clamp(position.y, bounds.position.y, bounds.end.y)

func moveXMultiplier(moveX):
	match moveX:
		MoveX.Left: return -1
		MoveX.Right: return 1
		MoveX.Stop: return 0

enum TurnDir { CCW, Stop, CW }
func turnTurret(timeDelta: float, turnDir):
	$Turret.rotation = clamp($Turret.rotation + timeDelta * turnDirMultiplier(turnDir) * turnSpeed, -maxTurnAngle, maxTurnAngle)

func turnDirMultiplier(turnDir):
	match turnDir:
		TurnDir.CCW: return -1
		TurnDir.CW: return 1
		TurnDir.Stop: return 0
