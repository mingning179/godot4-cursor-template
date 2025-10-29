extends Node

# 游戏状态枚举
enum GameState {
	READY,      # 准备状态
	PLAYING,    # 游戏中
	GAME_OVER   # 游戏结束
}

# 信号定义
signal score_changed(new_score: int)
signal combo_changed(new_combo: int)
signal game_state_changed(new_state: GameState)
signal game_over

# 游戏数据
var score: int = 0
var combo: int = 0
var game_state: GameState = GameState.READY
var best_score: int = 0

# 常量
const PERFECT_BONUS: int = 10  # 完美跳跃额外分数
const GOOD_BONUS: int = 5      # 良好落地额外分数
const COMBO_MULTIPLIER: float = 1.5  # 连击倍数
const DISTANCE_BONUS_MULTIPLIER: float = 0.5  # 距离奖励系数（每单位距离）

func _ready() -> void:
	load_best_score()

# 开始游戏
func start_game() -> void:
	score = 0
	combo = 0
	game_state = GameState.PLAYING
	score_changed.emit(score)
	combo_changed.emit(combo)
	game_state_changed.emit(game_state)

# 增加分数（带精准度和距离奖励）
func add_score(points: int, is_perfect: bool = false, distance: float = 0.0) -> void:
	if game_state != GameState.PLAYING:
		return
	
	# 如果是负分（扣分），直接扣除
	if points < 0:
		score = max(0, score + points)  # 分数不会低于0
		score_changed.emit(score)
		# 扣分时重置连击
		if combo > 0:
			combo = 0
			combo_changed.emit(combo)
		return
	
	var total_points: int = points
	
	# 距离奖励（跳得越远奖励越高）
	if distance > 0:
		var distance_bonus: int = int(distance * DISTANCE_BONUS_MULTIPLIER)
		total_points += distance_bonus
	
	# 精准度奖励
	if is_perfect:
		# 完美落地：最高奖励 + 保持连击
		total_points += PERFECT_BONUS
		combo += 1
		combo_changed.emit(combo)
		# 连击加成（连击越高倍数越高）
		if combo > 1:
			total_points = int(total_points * (1.0 + (combo - 1) * 0.1))
	else:
		# 普通落地：小额奖励 + 重置连击
		total_points += GOOD_BONUS
		if combo > 0:
			combo = 0
			combo_changed.emit(combo)
	
	score += total_points
	score_changed.emit(score)

# 结束游戏
func end_game() -> void:
	if game_state == GameState.GAME_OVER:
		return
	
	game_state = GameState.GAME_OVER
	
	# 更新最高分
	if score > best_score:
		best_score = score
		save_best_score()
	
	game_state_changed.emit(game_state)
	game_over.emit()

# 重置游戏
func reset_game() -> void:
	start_game()

# 保存最高分
func save_best_score() -> void:
	var file: FileAccess = FileAccess.open("user://best_score.save", FileAccess.WRITE)
	if file:
		file.store_32(best_score)
		file.close()

# 加载最高分
func load_best_score() -> void:
	if FileAccess.file_exists("user://best_score.save"):
		var file: FileAccess = FileAccess.open("user://best_score.save", FileAccess.READ)
		if file:
			best_score = file.get_32()
			file.close()

