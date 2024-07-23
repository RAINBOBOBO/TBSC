class_name BaseCharacter extends CharacterBody2D

enum States {IDLE, RUN}

const ACCELERATION = 3000
const FRICTION = 3000
const MAX_SPEED = 200

var state = States.IDLE

@onready var animation_player: AnimationPlayer = %AnimationPlayer


func _physics_process(delta: float) -> void:
	move(delta)
	attack()


func apply_friction(amount: float) -> void:
	if velocity.length() > amount:
		velocity -= velocity.normalized() * amount
	else:
		velocity = Vector2.ZERO


func apply_movement(amount: Vector2) -> void:
	velocity += amount
	velocity = velocity.limit_length(MAX_SPEED)


func attack() -> void:
	if Input.is_action_just_pressed("primary_attack"):
		animation_player.play()


func move(delta: float):
	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if input_vector == Vector2.ZERO:
		state = States.IDLE
		apply_friction(FRICTION * delta)
	else:
		state = States.RUN
		apply_movement(input_vector * ACCELERATION * delta)

	move_and_slide()
