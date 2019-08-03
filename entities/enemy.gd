extends KinematicBody2D

export (PackedScene) var AmmoType
export var speed = 200

onready var Player = $"../player"
onready var clipazine = get_parent()
onready var Gun = $Gun

var gun_has_my_ammo = false
var walk_target = null

func _ready():
	Gun.clipazine = clipazine

func _physics_process(delta):
	var space_state = get_world_2d().direct_space_state
	var player_pos = Player.global_position
	var ignored = [self, Player]
	var intersected = space_state.intersect_ray(global_position, player_pos, ignored)
	
	if intersected.empty(): # We can see the player
		player_spotted_at(Player.global_position)
	
	if walk_target && not at_position(walk_target):
		move_to(walk_target)

func at_position(target_pos):
	var x_distance = target_pos.x - position.x
	var y_distance = target_pos.y - position.y
	var distance = sqrt(pow(x_distance, 2) + pow(y_distance, 2))
	
	return distance < 100

func move_to(target_pos):
	var dir = target_pos - global_position
	rotation = dir.angle()
	var velocity = Vector2(speed, 0).rotated(rotation)
	move_and_slide(velocity)

func player_spotted_at(player_pos):
	var dir = player_pos - global_position
	walk_target = Vector2(player_pos.x, player_pos.y)
	rotation = dir.angle()
	shoot()

func shoot():
	if gun_has_my_ammo:
		var bullet = Gun.next_shot()
		var shoot = Gun.shoot()
		if (shoot == Gun.SHOT):
			gun_has_my_ammo = false
	else:
		if Gun.reload(AmmoType) == Gun.RELOADED:
			gun_has_my_ammo = true

func hit():
	queue_free()
