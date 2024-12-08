extends Node

@export var mob_scene: PackedScene
var score
var max_mobs = 10  # Ограничение на количество врагов
var mobs = []  # Список всех активных врагов
var player # Игрок

func _ready():
	player = $Player  # Привязка игрока к переменной, предполагается, что в сцене есть узел Player

func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()

func new_game():
	get_tree().call_group(&"enemies", &"queue_free")
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$Music.play()

func _on_MobTimer_timeout():
	if mobs.size() < max_mobs:
		# Create a new instance of the Mob scene.
		var mob = mob_scene.instantiate()

		# Choose a random location on Path2D.
		var mob_spawn_location = get_node(^"MobPath/MobSpawnLocation")
		mob_spawn_location.progress = randi()

		# Set the mob's position to a random location.
		mob.position = mob_spawn_location.position

		# Add the mob to the mobs list
		mobs.append(mob)

		# Add the mob to the scene
		add_child(mob)

		# Set the mob's initial state (static, waiting for player)
		mob.set("is_active", false)

func _on_ScoreTimer_timeout():
	score += 1
	$HUD.update_score(score)

func _on_StartTimer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()

# Функция, которая обновляет состояние врагов (статичные или преследуют)
func _process(delta):
	for mob in mobs:
		if is_instance_valid(mob):  # Проверка, существует ли объект
			if mob.position.distance_to(player.position) < 200:
				# Враг начинает преследовать
				mob.set("is_active", true)
			elif mob.position.distance_to(player.position) > 300:
				# Враг останавливается
				mob.set("is_active", false)
			if mob.get("is_active"):
				# Делаем врага движущимся к игроку
				var direction = (player.position - mob.position).normalized()
				mob.position += direction * mob.speed * delta
