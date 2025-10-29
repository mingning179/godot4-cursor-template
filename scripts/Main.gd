extends Node3D

# 预加载场景
const PLAYER_SCENE: PackedScene = preload("res://scenes/Player.tscn")

# 节点引用
@onready var camera: Camera3D = $Camera3D
@onready var platform_spawner: Node3D = $PlatformSpawner
@onready var game_ui: Control = $GameUI
@onready var target_indicator: MeshInstance3D = $TargetIndicator

# 变量
var player: CharacterBody3D = null
var camera_offset: Vector3 = Vector3(0, 12, 12)  # 更高更远的视角
var camera_smooth_speed: float = 3.0  # 更平滑的跟随

func _ready() -> void:
	setup_game()

func _process(delta: float) -> void:
	# 摄像机跟随玩家
	if player:
		update_camera(delta)

# 设置游戏
func setup_game() -> void:
	# 创建玩家
	player = PLAYER_SCENE.instantiate()
	add_child(player)
	
	# 设置玩家初始位置
	if platform_spawner:
		var start_pos: Vector3 = platform_spawner.get_start_position()
		player.reset_player(start_pos)
		
		# 设置初始目标平台
		if platform_spawner.platforms.size() > 1:
			var next_platform: Node3D = platform_spawner.platforms[1]
			player.set_next_platform(next_platform)
			# 更新目标指示器
			if target_indicator:
				target_indicator.set_target(next_platform)
		
		# 连接玩家信号
		player.landed.connect(_on_player_landed)
		player.fell_off.connect(_on_player_fell_off)
		player.charge_started.connect(_on_charge_started)
		player.charge_updated.connect(_on_charge_updated)
		player.jumped.connect(_on_player_jumped)
	
	# 设置摄像机初始位置（跟随模式）
	if player:
		camera.position = player.position + camera_offset
		var look_target: Vector3 = player.position
		look_target.y += 0.5
		camera.look_at(look_target, Vector3.UP)
	
	# 开始游戏
	var game_manager: Node = get_node("/root/GameManager")
	if game_manager:
		game_manager.start_game()

# 更新摄像机
func update_camera(delta: float) -> void:
	# 平滑跟随玩家位置
	var target_position: Vector3 = player.position + camera_offset
	camera.position = camera.position.lerp(target_position, camera_smooth_speed * delta)
	
	# 始终看向玩家中心位置
	var look_target: Vector3 = player.position
	look_target.y += 0.5
	camera.look_at(look_target, Vector3.UP)

# 玩家落地
func _on_player_landed(position: Vector3, platform: Node3D) -> void:
	
	# 通知平台生成器
	if platform_spawner:
		platform_spawner.on_player_landed(platform)
		
		# 设置玩家的下一个目标平台
		if player:
			var next_platform: Node3D = platform_spawner.get_next_platform(platform)
			if next_platform:
				player.set_next_platform(next_platform)
				# 更新目标指示器
				if target_indicator:
					target_indicator.set_target(next_platform)
	
	# 隐藏蓄力条
	if game_ui:
		game_ui.hide_charge_bar()

# 玩家掉落
func _on_player_fell_off() -> void:
	pass

# 开始蓄力
func _on_charge_started() -> void:
	pass

# 蓄力更新
func _on_charge_updated(charge_power: float) -> void:
	if game_ui:
		game_ui.update_charge(charge_power)

# 玩家跳跃
func _on_player_jumped(power: float) -> void:
	pass
