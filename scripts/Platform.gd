extends StaticBody3D

# 平台类型
enum PlatformType {
	NORMAL,   # 普通平台
	SMALL,    # 小平台
	LARGE     # 大平台
}

# 导出变量
@export var platform_type: PlatformType = PlatformType.NORMAL

# 节点引用
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

# 平台尺寸
var platform_size: Vector3 = Vector3(3, 0.8, 3)  # 增大平台尺寸

# 中心区域范围（用于判断是否完美跳跃）
var perfect_radius: float = 0.3

# 标志：是否已经设置过
var is_setup: bool = false

func _ready() -> void:
	# 如果还没有设置过，则自动设置
	if not is_setup:
		setup_platform()

# 设置平台
func setup_platform() -> void:
	match platform_type:
		PlatformType.NORMAL:
			platform_size = Vector3(3, 0.8, 3)  # 增大
			perfect_radius = 0.5
		PlatformType.SMALL:
			platform_size = Vector3(2, 0.8, 2)  # 增大
			perfect_radius = 0.3
		PlatformType.LARGE:
			platform_size = Vector3(4, 0.8, 4)  # 增大
			perfect_radius = 0.6
	
	# 设置网格
	if mesh_instance:
		var box_mesh: BoxMesh = BoxMesh.new()
		box_mesh.size = platform_size
		mesh_instance.mesh = box_mesh
		
		# 创建材质
		var material: StandardMaterial3D = StandardMaterial3D.new()
		var color: Color = get_platform_color()
		material.albedo_color = color
		material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
		material.disable_receive_shadows = false
		
		# 添加金属度和粗糙度，让材质更真实
		material.metallic = 0.2
		material.roughness = 0.7
		
		# 添加发光效果
		material.emission_enabled = true
		material.emission = color * 0.3
		material.emission_energy_multiplier = 1.0
		
		# 添加边缘光效果
		material.rim_enabled = true
		material.rim = 0.5
		material.rim_tint = 0.8
		
		mesh_instance.set_surface_override_material(0, material)
		
		# 确保mesh_instance可见
		mesh_instance.visible = true
	
	# 设置碰撞形状
	if collision_shape:
		var box_shape: BoxShape3D = BoxShape3D.new()
		box_shape.size = platform_size
		collision_shape.shape = box_shape
	
	# 标记为已设置
	is_setup = true

# 获取平台颜色
func get_platform_color() -> Color:
	match platform_type:
		PlatformType.NORMAL:
			return Color(1.0, 1.0, 1.0)  # 白色
		PlatformType.SMALL:
			return Color(1.0, 0.5, 0.5)  # 红色
		PlatformType.LARGE:
			return Color(0.5, 1.0, 0.5)  # 绿色
	return Color.WHITE

# 检查是否完美落地
func is_perfect_landing(landing_position: Vector3) -> bool:
	var platform_center: Vector3 = global_position
	platform_center.y = landing_position.y  # 只检查XZ平面
	var distance: float = platform_center.distance_to(landing_position)
	return distance <= perfect_radius

# 获取平台中心位置
func get_center_position() -> Vector3:
	return global_position + Vector3(0, platform_size.y / 2, 0)
