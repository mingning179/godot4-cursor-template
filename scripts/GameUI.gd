extends Control

# 节点引用
@onready var score_label: Label = $MarginContainer/VBoxContainer/ScoreLabel
@onready var combo_label: Label = $MarginContainer/VBoxContainer/ComboLabel
@onready var charge_bar: ProgressBar = $ChargeBar
@onready var game_over_panel: Panel = $GameOverPanel
@onready var final_score_label: Label = $GameOverPanel/VBoxContainer/FinalScoreLabel
@onready var best_score_label: Label = $GameOverPanel/VBoxContainer/BestScoreLabel
@onready var restart_button: Button = $GameOverPanel/VBoxContainer/RestartButton
@onready var start_hint: Label = $StartHint

func _ready() -> void:
	# 连接游戏管理器信号
	var game_manager: Node = get_node("/root/GameManager")
	if game_manager:
		game_manager.score_changed.connect(_on_score_changed)
		game_manager.combo_changed.connect(_on_combo_changed)
		game_manager.game_state_changed.connect(_on_game_state_changed)
		game_manager.game_over.connect(_on_game_over)
	
	# 初始化UI
	charge_bar.visible = false
	game_over_panel.visible = false
	start_hint.visible = true
	
	# 连接按钮
	restart_button.pressed.connect(_on_restart_pressed)

# 分数变化
func _on_score_changed(new_score: int) -> void:
	score_label.text = "分数: %d" % new_score

# 连击变化
func _on_combo_changed(new_combo: int) -> void:
	if new_combo > 1:
		combo_label.visible = true
		combo_label.text = "连击: x%d" % new_combo
		# 添加动画效果
		var tween: Tween = create_tween()
		tween.tween_property(combo_label, "scale", Vector2(1.2, 1.2), 0.1)
		tween.tween_property(combo_label, "scale", Vector2.ONE, 0.1)
	else:
		combo_label.visible = false

# 游戏状态变化
func _on_game_state_changed(new_state: int) -> void:
	match new_state:
		0:  # READY
			start_hint.visible = false  # 不显示提示
			game_over_panel.visible = false
		1:  # PLAYING
			start_hint.visible = false
			game_over_panel.visible = false
		2:  # GAME_OVER
			start_hint.visible = false

# 游戏结束
func _on_game_over() -> void:
	var game_manager: Node = get_node("/root/GameManager")
	if game_manager:
		final_score_label.text = "最终分数: %d" % game_manager.score
		best_score_label.text = "最高分数: %d" % game_manager.best_score
	
	game_over_panel.visible = true

# 更新蓄力条
func update_charge(charge_value: float) -> void:
	charge_bar.visible = true
	charge_bar.value = charge_value * 100

# 隐藏蓄力条
func hide_charge_bar() -> void:
	charge_bar.visible = false

# 重新开始按钮
func _on_restart_pressed() -> void:
	# 通知主场景重新开始游戏
	get_tree().reload_current_scene()

