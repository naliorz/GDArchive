extends CharacterBody2D

const STEERING_SPEED = 60

# car spec (cm)
const WIDTH = 184.2
const TRACK = 156.4
const FRONT_OVERHANG = 88.0
const WHEELBASE = 282.0
const REAR_OVERHANG = 102.6
const TIRE_SIZE = Vector2(22.5, 65.7)
const TURNING_RADIUS = 580.0

var size: Vector2
var front_left_wheel_position: Vector2
var front_right_wheel_position: Vector2
var rear_left_wheel_position: Vector2
var rear_right_wheel_position: Vector2
var max_angle: float

var angle_i = 0
var angle_o = 0
var dist_ic = INF
var dist_oc = INF
var turning_center = Vector2(INF, INF)

func _ready():
	size = Vector2(WIDTH, FRONT_OVERHANG + WHEELBASE + REAR_OVERHANG)
	front_left_wheel_position = Vector2(-TRACK / 2, -(size.y / 2 - FRONT_OVERHANG))
	front_right_wheel_position = Vector2(TRACK / 2, -(size.y / 2 - FRONT_OVERHANG))
	rear_left_wheel_position = Vector2(-TRACK / 2, size.y / 2 - REAR_OVERHANG)
	rear_right_wheel_position = Vector2(TRACK / 2, size.y / 2 - REAR_OVERHANG)
	
	max_angle = rad_to_deg(asin(WHEELBASE / (TURNING_RADIUS - TIRE_SIZE.x / 2)))
	
	$CollisionShape2D.shape.size = size

func _draw():
	var rect = Rect2(-size / 2, size)
	draw_rect(rect, Color.WHITE, false)
	
	draw_circle(turning_center, 10, Color.RED)
	draw_line(turning_center, front_left_wheel_position, Color.RED)
	draw_line(turning_center, front_right_wheel_position, Color.RED)
	draw_line(turning_center, rear_left_wheel_position, Color.RED)
	draw_line(turning_center, rear_right_wheel_position, Color.RED)
	
	var rad_left = 0
	var rad_right = 0
	if angle_o < 0:
		rad_left = deg_to_rad(angle_i)
		rad_right = deg_to_rad(angle_o)
	if angle_o > 0:
		rad_left = deg_to_rad(angle_o)
		rad_right = deg_to_rad(angle_i)
	
	draw_set_transform(front_left_wheel_position, rad_left)
	draw_rect(Rect2(-TIRE_SIZE / 2, TIRE_SIZE), Color.RED)
	draw_set_transform(front_right_wheel_position, rad_right)
	draw_rect(Rect2(-TIRE_SIZE / 2, TIRE_SIZE), Color.RED)
	draw_set_transform(rear_left_wheel_position, 0)
	draw_rect(Rect2(-TIRE_SIZE / 2, TIRE_SIZE), Color.RED)
	draw_set_transform(rear_right_wheel_position, 0)
	draw_rect(Rect2(-TIRE_SIZE / 2, TIRE_SIZE), Color.RED)
	

func _physics_process(delta):
	if Input.is_action_pressed("steer_left"):
		angle_o -= STEERING_SPEED * delta
	if Input.is_action_pressed("steer_right"):
		angle_o += STEERING_SPEED * delta
	
	angle_o = clamp(angle_o, -max_angle, max_angle)
	dist_oc = WHEELBASE / tan(deg_to_rad(angle_o))
	dist_ic = dist_oc - sign(dist_oc) * TRACK
	angle_i = rad_to_deg(atan(WHEELBASE / dist_ic))
	
	var rear_center = (rear_left_wheel_position + rear_right_wheel_position) / 2
	turning_center = rear_center + Vector2(dist_ic + dist_oc, 0) / 2
	
	if Input.is_action_pressed("forward"):
		var sign = sign(angle_o)
		if sign == 0:
			sign = 1
		var d = 10
		var t = Transform2D(0, turning_center)
		var r = Transform2D(sign * d / turning_center.length(), Vector2())
		transform = transform * t * r * t.inverse()
	
	queue_redraw()

