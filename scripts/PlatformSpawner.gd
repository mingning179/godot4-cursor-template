extends Node3D

# 信号
signal platform_spawned(platform: Node3D)

# 预加载场景
const PLATFORM_SCENE: PackedScene = preload("res://scenes/Platform.tscn")

# 导出变量
@export var min_distance: float = 3.0    # 最小距离
@export var max_distance: float = 6.0    # 最大距离
@export var initial_platforms: int = 5   # 初始平台数量
@export var max_platforms: int = 10      # 最大平台数量

# 变量
var platforms: Array[Node3D] = []
var current_platform_index: int = 0
var last_platform_position: Vector3 = Vector3.ZERO
var spawn_directions: Array[Vector3] = [
	Vector3.FORWARD,
	Vector3.RIGHT,
	Vector3(1, 0, 1).normalized(),
	Vector3(-1, 0, 1).normalized()
]

func _ready() -> void:
	# 创建初始平台
	spawn_initial_platforms()

# 生成初始平台
func spawn_initial_platforms() -> void:
	# 第一个平台（起始平台）
	var start_platform: Node3D = spawn_platform(Vector3.ZERO)
	if start_platform:
		platforms.append(start_platform)
	
	# 生成后续平台
	for i in range(initial_platforms - 1):
		spawn_next_platform()

# 生成下一个平台
func spawn_next_platform() -> Node3D:
	var max_attempts: int = 20  # 增加到20次尝试
	var new_position: Vector3
	var is_valid_position: bool = false
	
	for attempt in range(max_attempts):
		# 随机选择方向
		var direction: Vector3 = spawn_directions[randi() % spawn_directions.size()]
		
		# 随机距离（如果前几次失败，逐渐增加距离）
		var distance_min: float = min_distance + (attempt * 0.3)  # 失败越多，距离越远
		var distance_max: float = max_distance + (attempt * 0.5)
		var distance: float = randf_range(distance_min, distance_max)
		
		# 计算新位置
		new_position = last_platform_position + direction * distance
		
		# 随机高度变化
		new_position.y += randf_range(-0.5, 0.5)
		
		# 检查是否与现有平台重叠
		if is_position_valid(new_position):
			is_valid_position = true
			break
	
	# 如果还是找不到，强制使用远距离位置
	if not is_valid_position:
		print("警告：无法找到不重叠的平台位置，使用强制远距离位置")
		var forced_direction: Vector3 = spawn_directions[randi() % spawn_directions.size()]
		new_position = last_platform_position + forced_direction * (max_distance + 3.0)  # 强制远离
	
	# 生成平台
	var platform: Node3D = spawn_platform(new_position)
	if platform:
		platforms.append(platform)
		
		# 移除过多的平台
		if platforms.size() > max_platforms:
			var old_platform: Node3D = platforms.pop_front()
			if old_platform:
				old_platform.queue_free()
		
		return platform
	
	return null

# 检查位置是否有效（不与现有平台重叠）
func is_position_valid(position: Vector3) -> bool:
	# 计算安全距离：考虑平台实际大小
	# 最大平台是4x4，半径2.0
	# 两个最大平台：2.0 + 2.0 + 2.5（安全边距）= 6.5
	var safe_distance: float = 6.5
	
	for existing_platform in platforms:
		if existing_platform:
			# 只检查XZ平面距离，忽略Y轴（高度）
			var pos_xz: Vector2 = Vector2(position.x, position.z)
			var existing_xz: Vector2 = Vector2(
				existing_platform.global_position.x, 
				existing_platform.global_position.z
			)
			var distance_xz: float = pos_xz.distance_to(existing_xz)
			
			# 考虑平台大小的重叠检测
			if distance_xz < safe_distance:
				return false  # 太近了，可能重叠
	
	return true  # 位置有效

# 生成平台
func spawn_platform(position: Vector3) -> Node3D:
	var platform: Node3D = PLATFORM_SCENE.instantiate()
	if platform:
		# 先设置平台类型（在add_child之前）
		var random_type: int = randi() % 10
		if random_type < 7:
			platform.platform_type = 0  # NORMAL
		elif random_type < 9:
			platform.platform_type = 2  # LARGE
		else:
			platform.platform_type = 1  # SMALL
		
		# 添加到场景树
		add_child(platform)
		
		# 设置位置（在add_child之后）
		platform.global_position = position
		last_platform_position = position
		
		# 手动调用setup以应用位置更新后的设置
		if platform.has_method("setup_platform"):
			platform.setup_platform()
		
		platform_spawned.emit(platform)
		return platform
	
	return null

# 当玩家跳到新平台时调用
func on_player_landed(platform: Node3D) -> void:
	# 检查是否需要生成新平台
	var platform_index: int = platforms.find(platform)
	if platform_index >= 0 and platform_index >= platforms.size() - 3:
		# 如果玩家接近最后的平台，生成新平台
		spawn_next_platform()

# 重置平台生成器
func reset_spawner() -> void:
	# 清除所有平台
	for platform in platforms:
		if platform:
			platform.queue_free()
	platforms.clear()
	
	# 重置位置
	last_platform_position = Vector3.ZERO
	current_platform_index = 0
	
	# 重新生成初始平台
	spawn_initial_platforms()

# 获取起始平台位置
func get_start_position() -> Vector3:
	if platforms.size() > 0 and platforms[0]:
		return platforms[0].global_position + Vector3(0, 1, 0)
	return Vector3(0, 1, 0)

# 获取下一个平台
func get_next_platform(current: Node3D) -> Node3D:
	var current_index: int = platforms.find(current)
	if current_index >= 0 and current_index < platforms.size() - 1:
		return platforms[current_index + 1]
	return null

