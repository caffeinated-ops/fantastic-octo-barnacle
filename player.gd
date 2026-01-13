extends Area2D
signal hit
const ATTACK_DELAY = 0.1
const ATTACK_DURATION = 2.0
const ATTACK_COOLDOWN_TIME = 2.0
@export var speed = 400
var screen_size

var attack_cooldown = 0.0
var attack_active = false
var attack_timer = 0.0
var attack_delay_timer = 0.0
var attack_damage_radius = 70.0
var attack_pulse_time = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Handle attack cooldown
	if attack_cooldown > 0:
		attack_cooldown -= delta

	# Handle attack delay timer
	if attack_delay_timer > 0:
		attack_delay_timer -= delta
		if attack_delay_timer <= 0:
			# Activate attack
			attack_active = true
			attack_timer = ATTACK_DURATION
			# Visual feedback - change color to indicate attack
			$AnimatedSprite2D.modulate = Color(1, 0.5, 0.5)  # Red tint
			queue_redraw()  # Update attack radius visualization

	# Handle attack duration
	if attack_active and attack_timer > 0:
		attack_timer -= delta
		attack_pulse_time += delta  # Update pulse time
		queue_redraw()  # Update pulsing effect
		if attack_timer <= 0:
			attack_active = false
			attack_cooldown = ATTACK_COOLDOWN_TIME
			attack_pulse_time = 0.0  # Reset pulse time
			# Reset visual feedback
			$AnimatedSprite2D.modulate = Color(1, 1, 1)
			queue_redraw()  # Update attack radius visualization

	var velocity =  Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed('move_left'):

		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed('move_up'):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	position += velocity * delta
	position  = position.clamp(Vector2.ZERO, screen_size)

	if velocity.x > 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.x < 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0

	# Handle attack input
	if (Input.is_action_just_pressed("attack") and
			attack_cooldown <= 0 and
			attack_delay_timer <= 0 and
			not attack_active):
		attack_delay_timer = ATTACK_DELAY

	# Update HUD with attack status
	var hud = get_node("/root/Main/HUD")
	hud.update_attack_status(attack_cooldown, attack_active)

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func _draw():
	if attack_active:
		# Draw attack radius circle with pulsing effect
		var center = Vector2(0, 3)  # Offset down by 3 pixels
		var pulse = sin(attack_pulse_time * 10) * 0.1 + 0.9  # Pulsing effect
		var current_radius = attack_damage_radius * pulse

		var color = Color(1, 0.3, 0.3, 0.4)  # Semi-transparent red
		var width = 4.0
		draw_circle(center, current_radius, color)
		# Draw inner circle for better visibility
		draw_circle(center, current_radius, Color(1, 0.6, 0.6, 0.7), false, width)

func _on_body_entered(body: Node2D) -> void:
	if attack_active:
		# Player is attacking - gain points and destroy mob
		Score.score += 1
		get_node("/root/Main/HUD").update_score()
		body.queue_free()
	else:
		# Player takes damage
		hit.emit()
		get_node("/root/Main/HUD").decrease_health()
		body.queue_free()
