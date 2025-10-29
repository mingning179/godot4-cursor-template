extends MeshInstance3D

# 目标平台
var target_platform: Node3D = null

# 闪烁效果
var blink_time: float = 0.0
var blink_speed: float = 2.0

func _ready() -> void:
	# 创建圆柱体网格作为指示器
	var cylinder_mesh: CylinderMesh = CylinderMesh.new()
	cylinder_mesh.height = 0.1
	cylinder_mesh.top_radius = 0.5
	cylinder_mesh.bottom_radius = 0.5
	mesh = cylinder_mesh
	
	# 创建材质
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(1, 0.9, 0, 0.6)  # 半透明金黄色
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.disable_receive_shadows = true
	
	# 添加发光让指示器更醒目
	material.emission_enabled = true
	material.emission = Color(1, 1, 0, 1)
	material.emission_energy_multiplier = 2.0
	
	# 添加边缘光
	material.rim_enabled = true
	material.rim = 1.0
	material.rim_tint = 1.0
	
	set_surface_override_material(0, material)
	
	visible = false  # 初始隐藏

func _process(delta: float) -> void:
	# 更新位置
	if target_platform:
		var target_pos: Vector3 = target_platform.global_position
		target_pos.y += 0.6  # 稍微高于平台
		global_position = target_pos
		
		# 闪烁效果
		blink_time += delta * blink_speed
		var alpha: float = (sin(blink_time) + 1.0) / 2.0 * 0.5 + 0.3
		var material: StandardMaterial3D = get_surface_override_material(0) as StandardMaterial3D
		if material:
			material.albedo_color.a = alpha

# 设置目标平台
func set_target(platform: Node3D) -> void:
	target_platform = platform
	visible = platform != null

