extends AnimatedSprite2D

const ACTIONS = {MOVE = preload('res://Resources/Actions/Avatar/avatar_move.tres'),
				PUNCH = preload('res://Resources/Actions/Avatar/avatar_punch.tres'),
				JUMP = preload('res://Resources/Actions/Avatar/avatar_jump.tres'),
				JUMP_ATTACK = preload('res://Resources/Actions/Avatar/avatar_punch.tres'),
				LAND = preload('res://Resources/Actions/Avatar/avatar_punch.tres'),
				WALL_JUMP = preload('res://Resources/Actions/Avatar/avatar_punch.tres'),
				SLIDE = preload('res://Resources/Actions/Avatar/avatar_punch.tres'),
				RECOVER = preload('res://Resources/Actions/Avatar/avatar_punch.tres')}

var grid_pos : Vector2
var unit_info : UnitInfo
var state = Constants.UNIT_STATES.IDLE
# 1 or -1
var direction = Vector2(1, 1)
var range_offset = 0

var _tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	animation = &"idle"

# need different trajectories depending on jump or run

# move, deal damage, animation
func perform_action(action, _grid_pos):
	var tile = Global.grid_to_tile[_grid_pos]
	if (_grid_pos.x - grid_pos.x < 0):
		flip_h = true
	elif (_grid_pos.x - grid_pos.x > 0):
		flip_h = false
		
	if flip_h:
		direction = Vector2(-1, 1)
	else:
		direction = Vector2(1, 1)
	
	match action:
		ACTIONS.MOVE:
			state = Constants.UNIT_STATES.RUNNING
			frame = 0
			play("run")
			move_straight(Global.grid_to_tile[_grid_pos].global_position, 75)
			
			Global.units[grid_pos] = null
			Global.units[tile.grid_pos] = self
			grid_pos = tile.grid_pos
			
		ACTIONS.JUMP:
			state = Constants.UNIT_STATES.IN_AIR
			frame = 0
			play("jump")
			move_straight(Global.grid_to_tile[_grid_pos].global_position, 75)
			
			Global.units[grid_pos] = null
			Global.units[tile.grid_pos] = self
			grid_pos = tile.grid_pos
			
		ACTIONS.PUNCH:
			state = Constants.UNIT_STATES.IDLE
			frame = 0
			play("punch")
			await animation_finished
			SignalBus.emit_signal('activate_grid')

func available_actions():
	match state:
		Constants.UNIT_STATES.IDLE:
			return [ACTIONS.MOVE, ACTIONS.JUMP, ACTIONS.PUNCH]
		Constants.UNIT_STATES.RUNNING:
			return [ACTIONS.MOVE, ACTIONS.JUMP, ACTIONS.PUNCH]
		Constants.UNIT_STATES.AT_WALL:
			return [ACTIONS.WALL_JUMP, ACTIONS.SLIDE]
		Constants.UNIT_STATES.HIT:
			return [ACTIONS.RECOVER]
		Constants.UNIT_STATES.IN_AIR:
			return [ACTIONS.JUMP_ATTACK, ACTIONS.LAND]
		Constants.UNIT_STATES.WINDUP:
			return []

# new pos is vector2 for new global position.
func move_straight(new_pos, speed):
	var dist = global_position.distance_to(new_pos)
	var time = dist / speed
	_tween = get_tree().create_tween()
	_tween.tween_property(self, 'global_position', new_pos, time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	_tween.tween_callback(pause)
	_tween.tween_callback(SignalBus.emit_signal.bind('activate_grid'))


func move_parabolic(new_pos):
	pass