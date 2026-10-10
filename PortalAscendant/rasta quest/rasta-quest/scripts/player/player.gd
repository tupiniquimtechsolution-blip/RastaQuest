extends CharacterBody2D

# ===== SINAIS (HUD / GAME MANAGER) =====
signal life_changed(value)
signal score_changed(value)

# ===== STATUS =====
@export var speed := 180.0
@export var jump_force := -360.0
@export var gravity := 900.0

var life := 100
var score := 0
var is_attacking := false
var is_dead := false

# ===== NÓS =====
@onready var anim = $AnimatedSprite2D
@onready var combat = $PlayerCombat
@onready var stats = $PlayerStats
@onready var anim_ctrl = $PlayerAnimations

# ===== LOOP =====
func _ready():
	anim.play("idle")
	life_changed.emit(life)
	score_changed.emit(score)

func _physics_process(delta):
	if is_dead:
		return

	apply_gravity(delta)
	handle_movement()
	handle_jump()
	move_and_slide()
	anim_ctrl.update_animation(velocity, is_attacking)

# ===== MOVIMENTO =====
func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func handle_movement():
	if is_attacking:
		velocity.x = 0
		return

	var dir := Input.get_axis("ui_left", "ui_right")
	velocity.x = dir * speed
	if dir != 0:
		anim.flip_h = dir < 0

func handle_jump():
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not is_attacking:
		velocity.y = jump_force

# ===== COMBATE / STATUS =====
func take_damage(amount: int):
	if is_dead:
		return
	life -= amount
	life_changed.emit(life)
	if life <= 0:
		die()

func add_score(amount: int):
	score += amount
	score_changed.emit(score)

func die():
	is_dead = true
	velocity = Vector2.ZERO
	anim_ctrl.play("death")
