extends Area2D

signal hit

@export var speed = 400  # Скорость движения игрока (пикселей в секунду).

var screen_size  # Размер экрана.
var raycast_up : RayCast2D
var raycast_down : RayCast2D
var raycast_left : RayCast2D
var raycast_right : RayCast2D
var raycast_up_left : RayCast2D
var raycast_up_right : RayCast2D
var raycast_down_left : RayCast2D
var raycast_down_right : RayCast2D

func _ready():
	screen_size = get_viewport_rect().size
	hide()

	# Инициализируем все лучи
	raycast_up = $RayCastUp
	raycast_down = $RayCastDown
	raycast_left = $RayCastLeft
	raycast_right = $RayCastRight
	raycast_up_left = $RayCastUpLeft
	raycast_up_right = $RayCastUpRight
	raycast_down_left = $RayCastDownLeft
	raycast_down_right = $RayCastDownRight
	
	# Включаем все лучи
	raycast_up.enabled = true
	raycast_down.enabled = true
	raycast_left.enabled = true
	raycast_right.enabled = true
	raycast_up_left.enabled = true
	raycast_up_right.enabled = true
	raycast_down_left.enabled = true
	raycast_down_right.enabled = true

func _process(delta):
	var velocity = Vector2.ZERO  # Вектор движения персонажа.
	
	# Проверка наличия врагов с помощью лучей
	var dodge_direction = Vector2.ZERO

	# Проверка столкновений с врагами
	if raycast_up.is_colliding() and raycast_up.get_collider().is_in_group("enemies"):
		dodge_direction = Vector2(0, 1)  # Вниз
	elif raycast_down.is_colliding() and raycast_down.get_collider().is_in_group("enemies"):
		dodge_direction = Vector2(0, -1)  # Вверх
	elif raycast_left.is_colliding() and raycast_left.get_collider().is_in_group("enemies"):
		dodge_direction = Vector2(1, 0)  # Вправо
	elif raycast_right.is_colliding() and raycast_right.get_collider().is_in_group("enemies"):
		dodge_direction = Vector2(-1, 0)  # Влево
	elif raycast_up_left.is_colliding() and raycast_up_left.get_collider().is_in_group("enemies"):
		dodge_direction = Vector2(1, 1)  # Вниз-вправо
	elif raycast_up_right.is_colliding() and raycast_up_right.get_collider().is_in_group("enemies"):
		dodge_direction = Vector2(-1, 1)  # Вниз-влево
	elif raycast_down_left.is_colliding() and raycast_down_left.get_collider().is_in_group("enemies"):
		dodge_direction = Vector2(1, -1)  # Вверх-вправо
	elif raycast_down_right.is_colliding() and raycast_down_right.get_collider().is_in_group("enemies"):
		dodge_direction = Vector2(-1, -1)  # Вверх-влево
	
	# Если враг обнаружен, убегаем в противоположную сторону
	if dodge_direction != Vector2.ZERO:
		# Вычисляем противоположное направление уклонения
		var flee_direction = -dodge_direction.normalized()

		# Применяем уклонение
		velocity = flee_direction * speed
	else:
		# Обычное движение по клавишам
		if Input.is_action_pressed("move_right"):
			velocity.x += 1
		if Input.is_action_pressed("move_left"):
			velocity.x -= 1
		if Input.is_action_pressed("move_down"):
			velocity.y += 1
		if Input.is_action_pressed("move_up"):
			velocity.y -= 1

		if velocity.length() > 0:
			velocity = velocity.normalized() * speed
			$AnimatedSprite2D.play()
		else:
			$AnimatedSprite2D.stop()

	# Применяем движение
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	# Обновляем анимацию
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "right"
		$AnimatedSprite2D.flip_v = false
		$Trail.rotation = 0
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		rotation = PI if velocity.y > 0 else 0

func start(pos):
	position = pos
	rotation = 0
	show()
	$CollisionShape2D.disabled = false

func _on_body_entered(_body):
	hide()  # Игрок исчезает после того как его задел враг
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)
