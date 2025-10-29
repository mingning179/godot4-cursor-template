extends Node3D

@onready var camera: Camera3D = $Camera3D
@onready var ui: Control = $UI

func _ready() -> void:
    print("游戏启动！")
    setup_camera()

func setup_camera() -> void:
    camera.position = Vector3(0, 5, 10)
    camera.look_at(Vector3.ZERO, Vector3.UP)
