extends CharacterBody2D

const SPEED = 300.0
const JUMP_SPEED = 400.0
const GRAVITY = 1200.0

# Player 1 keys (player 2 gets different ones in _ready)
var key_left = KEY_A
var key_right = KEY_D
var key_up = KEY_W
var key_down = KEY_S
var key_jump = KEY_SPACE
var key_dash = KEY_Z
var key_attack = KEY_X
var key_ultimate = KEY_C

var player = 1
var my_group = "player1"
var other_group = "player2"
var color = Color.LIME_GREEN

var hp = 100
var bar
var ui

var height = 0.0
var height_speed = 0.0
var jump_was_down = false

var facing = Vector2.RIGHT
var dash_time = 0.0
var dash_speed = 0.0
var dash_dir = Vector2.ZERO
var wait = 0.0

# knockback settings (change these to make the push stronger or weaker)
const KNOCKBACK_BASE = 400.0
const KNOCKBACK_PER_DAMAGE = 20.0
const KNOCKBACK_FRICTION = 1500.0
var knock_velocity = Vector2.ZERO

@onready var sprite = $AnimatedSprite2D
@onready var start_y = sprite.position.y


func _ready():
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	if str(name).contains("2"):
		player = 2
		key_left = KEY_LEFT
		key_right = KEY_RIGHT
		key_up = KEY_UP
		key_down = KEY_DOWN
		key_jump = KEY_SHIFT
		key_dash = KEY_COMMA
		key_attack = KEY_PERIOD
		key_ultimate = KEY_SLASH
		my_group = "player2"
		other_group = "player1"
		color = Color.ORANGE_RED
		facing = Vector2.LEFT
		sprite.flip_h = true
		position.x += 400
	add_to_group(my_group)
	make_ui()


func _physics_process(delta):
	# walking
	var dir = Vector2(
		int(Input.is_physical_key_pressed(key_right)) - int(Input.is_physical_key_pressed(key_left)),
		int(Input.is_physical_key_pressed(key_down)) - int(Input.is_physical_key_pressed(key_up)))
	if dir != Vector2.ZERO:
		velocity = dir.normalized() * SPEED
		facing = dir.normalized()
	else:
		velocity = Vector2.ZERO

	# dash
	if dash_time > 0:
		dash_time -= delta
		velocity = dash_dir * dash_speed

	# knockback (pushes the player back after being hit)
	if knock_velocity != Vector2.ZERO:
		velocity += knock_velocity
		knock_velocity = knock_velocity.move_toward(Vector2.ZERO, KNOCKBACK_FRICTION * delta)

	# jump (one press = one jump, gravity pulls you back down)
	var jump_down = Input.is_physical_key_pressed(key_jump)
	if jump_down and not jump_was_down and height == 0.0:
		height_speed = JUMP_SPEED
	jump_was_down = jump_down

	height_speed -= GRAVITY * delta
	height += height_speed * delta
	if height < 0.0:
		height = 0.0
		height_speed = 0.0
	sprite.position.y = start_y - height

	move_and_slide()
	stay_on_floor()


func _process(delta):
	wait -= delta
	if wait <= 0:
		if Input.is_physical_key_pressed(key_dash):
			dash(900, 0)
		elif Input.is_physical_key_pressed(key_attack):
			dash(1100, 2)
		elif Input.is_physical_key_pressed(key_ultimate):
			# special attack: C for player 1, / for player 2
			wait = 2.0
			sprite.modulate = Color.GOLD
			hit_other_player(30, 220)

	sprite.modulate = sprite.modulate.lerp(Color.WHITE, 5 * delta)


func dash(speed, damage):
	dash_time = 0.2
	dash_speed = speed
	dash_dir = facing
	wait = 0.5
	if damage > 0:
		sprite.modulate = Color.ORANGE
		hit_other_player(damage, 100)
	else:
		sprite.modulate = Color.SKY_BLUE


func hit_other_player(damage, radius):
	for p in get_tree().get_nodes_in_group(other_group):
		if global_position.distance_to(p.global_position) < radius and p.height < 30.0:
			p.take_damage(damage)
			p.apply_knockback(global_position, damage)
			%AudioStreamPlayer2D.playing = true


func take_damage(amount):
	if get_tree().paused:
		return
	hp -= amount
	bar.value = hp
	sprite.modulate = Color.RED
	if amount >= 10:
		play_hurt_sound()
	if hp <= 0:
		game_over()


func apply_knockback(from_pos, damage):
	# push away from the player who hit us
	var dir_x = sign(global_position.x - from_pos.x)
	if dir_x == 0:
		dir_x = 1.0
	knock_velocity = Vector2(dir_x, 0) * (KNOCKBACK_BASE + damage * KNOCKBACK_PER_DAMAGE)
	dash_time = 0.0


func play_hurt_sound():
	print("hurt sound called")
	var path = "res://fahhh.mp3"
	if not ResourceLoader.exists(path):
		print("FILE NOT FOUND: ", path)
		return
	var sound = AudioStreamPlayer.new()
	sound.stream = load(path)
	sound.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(sound)
	sound.play()
	print("sound playing")
	sound.finished.connect(sound.queue_free)


func game_over():
	get_tree().paused = true
	var winner = "PLAYER 1"
	if player == 1:
		winner = "PLAYER 2"
	var label = Label.new()
	label.text = winner + " WINS!"
	label.add_theme_font_size_override("font_size", 60)
	label.position = get_viewport_rect().size / 2 - Vector2(230, 40)
	ui.add_child(label)
	await get_tree().create_timer(3.0).timeout
	get_tree().paused = false
	get_tree().reload_current_scene()


func stay_on_floor():
	# 0.6 = highest they can walk, 0.92 = lowest (fractions of screen height)
	var screen = get_viewport_rect().size
	var feet = global_position + Vector2(sprite.position.x, start_y)
	var fixed = feet.clamp(Vector2(30, screen.y * 0.6), Vector2(screen.x - 30, screen.y * 0.92))
	global_position += fixed - feet


func make_ui():
	var screen = get_viewport_rect().size

	# health bar in the bottom corner
	ui = CanvasLayer.new()
	add_child(ui)
	bar = ProgressBar.new()
	bar.value = hp
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(300, 28)
	bar.modulate = color
	if player == 1:
		bar.position = Vector2(20, screen.y - 48)
	else:
		bar.position = Vector2(screen.x - 320, screen.y - 48)
	ui.add_child(bar)

	# P1 / P2 label above the head
	var tag = Label.new()
	tag.text = "P" + str(player)
	tag.modulate = color
	tag.add_theme_font_size_override("font_size", 28)
	tag.position = Vector2(sprite.position.x - 16, start_y - 90)
	add_child(tag)

	# slight color tint on the character
	sprite.self_modulate = color.lerp(Color.WHITE, 0.6)
