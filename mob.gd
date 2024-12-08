extends RigidBody2D

@export var speed = 50  # Скорость преследования врага
@export var max_distance = 300  # Максимальное расстояние, на котором враг будет преследовать игрока
@export var detection_range = 200  # Радиус активации врага
var is_active = false
var player : Node2D  # Ссылка на игрока

func _ready():
	# Получаем ссылку на игрока в сцене
	player = get_node("/root/Main/Player")  # Укажите правильный путь до узла игрока

	$AnimatedSprite2D.play()
	var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = mob_types.pick_random()

	# Добавляем врага в группу "enemies"
	add_to_group("enemies")

func _process(delta):
	# Проверяем, что игрок в пределах радиуса активации
	if player:
		var distance_to_player = position.distance_to(player.position)

		# Если враг слишком далеко, он останавливается
		if distance_to_player > max_distance:
			is_active = false
			linear_velocity = Vector2.ZERO  # Останавливаем движение
		elif distance_to_player < detection_range:
			# Враг начинает преследовать игрока
			is_active = true
		else:
			# Враг перестаёт преследовать, если игрок слишком далеко
			is_active = false
			linear_velocity = Vector2.ZERO  # Останавливаем движение

	# Если враг активен, двигаем его к игроку
	if is_active:
		var direction = (player.position - position).normalized()
		linear_velocity = direction * speed
