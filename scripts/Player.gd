extends CharacterBody3D

# 信号
signal landed(position: Vector3, platform: Node3D)
signal fell_off
signal charge_started
signal charge_updated(charge_power: float)
signal jumped(power: float)

# 导出变量
@export var max_charge_time: float = 2.0  # 最大蓄力时间
@export var min_jump_force: float = 5.0   # 最小跳跃力
@export var max_jump_force: float = 15.0  # 最大跳跃力
@export var gravity: float = 20.0         # 重力

# 节点引用
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var ray_cast: RayCast3D = $RayCast3D

# 状态变量
var is_charging: bool = false
var charge_start_time: float = 0.0
var current_charge: float = 0.0
var is_jumping: bool = false
var jump_direction: Vector3 = Vector3.FORWARD
var current_platform: Node3D = null
var next_platform: Node3D = null
var can_jump: bool = true
var has_fallen: bool = false  # 防止重复触发掉落

# 玩家尺寸
var player_height: float = 1.5  # 增大尺寸，更容易看到

func _ready() -> void:
	setup_player()
	# 设置初始位置
	position = Vector3(0, 1, 0)

func _physics_process(delta: float) -> void:
	# 应用重力
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# 处理蓄力
	if is_charging:
		var charge_duration: float = Time.get_ticks_msec() / 1000.0 - charge_start_time
		current_charge = min(charge_duration / max_charge_time, 1.0)
		charge_updated.emit(current_charge)
		
		# 视觉反馈：蓄力时压缩
		var scale_y: float = 1.0 - (current_charge * 0.3)
		mesh_instance.scale = Vector3(1, scale_y, 1)
	
	# 移动
	move_and_slide()
	
	# 检测落地
	if is_jumping and is_on_floor():
		on_landed()
	
	# 检测掉落（只触发一次）
	if not has_fallen and position.y < -5.0:
		has_fallen = true
		on_fell_off()

func _unhandled_input(event: InputEvent) -> void:
	if not can_jump:
		return
	
	# 按下开始蓄力
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed:
				start_charge()
			else:
				release_jump()
	
	# 触屏支持
	if event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event as InputEventScreenTouch
		if touch_event.pressed:
			start_charge()
		else:
			release_jump()

# 设置玩家
func setup_player() -> void:
	# 创建圆柱体网格
	var cylinder_mesh: CylinderMesh = CylinderMesh.new()
	cylinder_mesh.height = player_height
	cylinder_mesh.top_radius = 0.5  # 增大半径
	cylinder_mesh.bottom_radius = 0.5
	mesh_instance.mesh = cylinder_mesh
	
	# 创建材质
	var material: StandardMaterial3D = StandardMaterial3D.new()
	var player_color: Color = Color(0.3, 0.6, 1.0)  # 鲜艳的蓝色
	material.albedo_color = player_color
	material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	material.disable_receive_shadows = false
	
	# 添加金属质感
	material.metallic = 0.6
	material.metallic_specular = 0.8
	material.roughness = 0.3
	
	# 添加发光效果
	material.emission_enabled = true
	material.emission = player_color * 0.6
	material.emission_energy_multiplier = 1.2
	
	# 添加边缘光
	material.rim_enabled = true
	material.rim = 0.7
	material.rim_tint = 1.0
	
	mesh_instance.set_surface_override_material(0, material)
	
	# 确保mesh_instance可见
	mesh_instance.visible = true
	
	# 设置碰撞形状
	var capsule_shape: CapsuleShape3D = CapsuleShape3D.new()
	capsule_shape.height = player_height
	capsule_shape.radius = 0.5  # 匹配网格半径
	collision_shape.shape = capsule_shape
	
	# 设置射线检测
	ray_cast.target_position = Vector3(0, -player_height, 0)
	ray_cast.enabled = true

# 开始蓄力
func start_charge() -> void:
	if is_jumping or not can_jump:
		return
	
	is_charging = true
	charge_start_time = Time.get_ticks_msec() / 1000.0
	current_charge = 0.0
	charge_started.emit()

# 释放跳跃
func release_jump() -> void:
	if not is_charging:
		return
	
	is_charging = false
	
	# 计算跳跃力
	var jump_force: float = lerp(min_jump_force, max_jump_force, current_charge)
	
	# 计算跳跃方向和速度（如果有下一个平台目标）
	if next_platform:
		var target_pos: Vector3 = next_platform.global_position
		var current_pos: Vector3 = global_position
		
		# 计算水平距离和高度差
		var horizontal_offset: Vector3 = target_pos - current_pos
		horizontal_offset.y = 0  # 只看水平距离
		var horizontal_distance: float = horizontal_offset.length()
		var height_diff: float = target_pos.y - current_pos.y
		
		# 计算水平方向
		var horizontal_direction: Vector3 = horizontal_offset.normalized()
		
		# 计算需要的速度
		# 使用抛物线运动，确保能跳过中间的障碍物
		var horizontal_speed: float = jump_force * 0.8
		var vertical_speed: float = jump_force * 1.2  # 增加垂直分量，跳得更高
		
		# 如果目标更高，增加垂直速度
		if height_diff > 0:
			vertical_speed += height_diff * 2.0
		
		# 设置速度
		velocity = horizontal_direction * horizontal_speed
		velocity.y = vertical_speed
		
	else:
		# 没有目标，使用默认方向
		velocity = jump_direction * jump_force
		velocity.y = jump_force * 1.2
	
	is_jumping = true
	can_jump = false
	
	# 恢复形状
	mesh_instance.scale = Vector3.ONE
	
	jumped.emit(jump_force)

# 落地处理
func on_landed() -> void:
	is_jumping = false
	velocity = Vector3.ZERO
	
	# 延迟一帧让物理稳定
	await get_tree().physics_frame
	
	# 重新启用跳跃
	can_jump = true
	
	# 检测落在哪个平台上
	if ray_cast.is_colliding():
		var collider: Node3D = ray_cast.get_collider() as Node3D
		if collider and collider.has_method("is_perfect_landing"):
			var previous_platform: Node3D = current_platform
			current_platform = collider
			
			# ⚠️ 关键修复：只有跳到目标平台才算成功
			if next_platform and collider == next_platform:
				# 跳到了正确的目标平台！
				
				# 计算跳跃距离（用于距离奖励）
				var jump_distance: float = 0.0
				if previous_platform:
					jump_distance = previous_platform.global_position.distance_to(collider.global_position)
				
				# 判断是否完美落地
				var is_perfect: bool = collider.is_perfect_landing(position)
				
				# 通知游戏管理器加分
				var game_manager: Node = get_node("/root/GameManager")
				if game_manager:
					game_manager.add_score(1, is_perfect, jump_distance)
				
				# 发射落地信号（会触发生成新平台和更新目标）
				landed.emit(position, current_platform)
				
			elif collider == previous_platform:
				# 跳回了原来的平台（原地跳或后退），扣分！
				var game_manager: Node = get_node("/root/GameManager")
				if game_manager:
					game_manager.add_score(-2, false, 0.0)  # 扣2分
				# ⚠️ 不更新目标，玩家需要继续跳到原目标
				
			elif not next_platform:
				# 还没有设置目标平台（游戏刚开始），允许但不加分
				# 发射信号以便设置第一个目标
				landed.emit(position, current_platform)
				
			else:
				# 跳到了错误的平台（不是目标也不是当前）
				print("跳到了错误的平台！游戏结束")
				on_fell_off()
		else:
			can_jump = true  # 即使不是平台也允许跳跃
	else:
		can_jump = true  # 允许跳跃

# 掉落处理
func on_fell_off() -> void:
	can_jump = false
	fell_off.emit()
	
	# 通知游戏管理器
	var game_manager: Node = get_node("/root/GameManager")
	if game_manager:
		game_manager.end_game()

# 重置玩家
func reset_player(start_position: Vector3) -> void:
	position = start_position
	velocity = Vector3.ZERO
	is_charging = false
	is_jumping = false
	can_jump = true
	has_fallen = false
	current_charge = 0.0
	mesh_instance.scale = Vector3.ONE

# 设置下一个目标平台
func set_next_platform(platform: Node3D) -> void:
	next_platform = platform

