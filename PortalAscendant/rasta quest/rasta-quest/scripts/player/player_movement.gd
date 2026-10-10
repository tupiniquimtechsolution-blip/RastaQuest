extends CharacterBody2D

@export var speed := 220.0
@export var jump_force := 420.0
@export var gravity := 1200.0

func _physics_process(delta):
	# Gravidade
	if not is_on_floor():
		velocity.y += gravity * delta

	# Movimento horizontal
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * speed

	# Pulo
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_force

	move_and_slide()
