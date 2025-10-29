extends MeshInstance3D

# 目标平台
var target_platform: Node3D = null

# 闪烁效果
var blink_time: float = 0.0
var blink_speed: float = 3.0  # 加快闪烁速度

# 圆环尺寸
var torus_mesh: TorusMesh = null

func _ready() -> void:
	# 创建圆环网格作为指示器
	torus_mesh = TorusMesh.new()
	torus_mesh.inner_radius = 1.0
	torus_mesh.outer_radius = 1.5
	torus_mesh.rings = 32
	torus_mesh.ring_segments = 16
	mesh = torus_mesh
	
	# 创建醒目的圆环材质
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(1, 0.9, 0, 1)  # 不透明亮黄色
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.disable_receive_shadows = true
	material.disable_ambient_light = true
	
	# 强发光效果
	material.emission_enabled = true
	material.emission = Color(1, 0.8, 0, 1)
	material.emission_energy_multiplier = 3.0  # 强烈发光
	
	set_surface_override_material(0, material)
	
	visible = false  # 初始隐藏

func _process(delta: float) -> void:
	# 更新位置和大小
	if target_platform and is_instance_valid(target_platform):
		var target_pos: Vector3 = target_platform.global_position
		
		# 计算平台高度，让圆环在平台表面
		var platform_height: float = 0.8  # 默认平台高度
		if target_platform.get("platform_size"):
			var size_vec: Vector3 = target_platform.get("platform_size")
			platform_height = size_vec.y
		
		# 圆环位置：平台表面（稍微高一点避免Z-fighting）
		target_pos.y += platform_height / 2.0 + 0.05
		global_position = target_pos
		
		# 根据平台的完美落地区域调整圆环大小
		var perfect_radius: float = 0.5  # 默认完美半径
		if target_platform.get("perfect_radius"):
			perfect_radius = target_platform.get("perfect_radius")
		
		# 圆环大小 = 完美落地区域（标记中心）
		if torus_mesh:
			torus_mesh.inner_radius = perfect_radius * 0.85
			torus_mesh.outer_radius = perfect_radius * 1.15
		
		# 脉冲式闪烁（强度变化而非透明度）
		blink_time += delta * blink_speed
		var pulse: float = (sin(blink_time) + 1.0) / 2.0 * 2.0 + 2.0  # 2.0-4.0范围
		var material: StandardMaterial3D = get_surface_override_material(0) as StandardMaterial3D
		if material:
			material.emission_energy_multiplier = pulse
		
		# 旋转动画增加立体感
		rotate_y(delta * 2.0)
		
		# 确保可见
		visible = true
	else:
		visible = false

# 设置目标平台
func set_target(platform: Node3D) -> void:
	target_platform = platform
	if platform:
		visible = true
	else:
		visible = false

