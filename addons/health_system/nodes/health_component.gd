@tool
class_name HealthComponent
extends Node

# this is the node that is added to any character, enemy, object or destructible in your scene.

# -- Exports --
# the maximum hp this entity starts with and can naturally reach
@export_range(1.0, 100000.0, 1.0, "or_greater") var max_hp: float = 100.0:
	set(value):
		max_hp = maxf(1.0, value)
		if _core != null:
			_core.set_max_hp(max_hp)
		update_configuration_warnings()

# If true, this component initializes and begins tracking health
@export var auto_initialize: bool = true

# -- Signals --
signal hp_changed(previous_hp: float, new_hp: float, delta: float)

signal max_hp_changed(previous_max: float, new_max: float)

signal died()

signal revived(restored_hp: float)

# -- Internal --
var _core: HealthCore = null
var _initialized: bool = false

# -- lifecycle --
func _ready() -> void:
	if Engine.is_editor_hint():
		update_configuration_warnings()
		return

	if auto_initialize:
		initialize()

func initialize(p_max_hp: float = -1.0) -> void:
	if p_max_hp > 0.0:
		max_hp = p_max_hp

	_core = HealthCore.new()
	_core.initialize(max_hp)
	_initialized = true

# -- Public API --
var current_hp: float:
	get:
		return _core.current_hp if _core != null else max_hp

func get_hp_ratio() -> float:	return _core.get_hp_ratio() if _core != null else 1.0

func is_alive() -> bool:
	return _core.is_alive() if _core != null else true

func set_hp(value: float) -> void:
	if not _initialized:
		push_warning("HealthComponent on '%s': set_hp() called before initialize()." % name)
		return

	var previous := _core.current_hp
	var new_value := _core.set_hp(value)
	var delta := new_value - previous

	if delta != 0.0:
		hp_changed.emit(previous, new_value, delta)

	if _core.current_hp <= 0.0 and not _core.is_dead:
		_trigger_death()

func set_max_hp(new_max: float, preserve_ratio: bool = false) -> void:
	if not _initialized:
		return
	var previous_max := _core.max_hp
	var previous_hp := _core.current_hp
	_core.set_max_hp(new_max, preserve_ratio)
	max_hp = _core.max_hp

	if _core.max_hp != previous_max:
		max_hp_changed.emit(previous_max, _core.max_hp)

	if _core.current_hp != previous_hp:
		hp_changed.emit(previous_hp, _core.current_hp, _core.current_hp - previous_hp)

func revive(restored_hp: float = -1.0) -> void:
	if not _initialized or _core.is_alive():
		return
	if restored_hp < 0.0:
		restored_hp = max_hp
	_core.mark_alive()
	var actual := _core.increase_hp(restored_hp)
	hp_changed.emit(0.0, _core.current_hp, actual)
	revived.emit(actual)

# -- internal --
func _trigger_death() -> void:
	_core.mark_dead()
	died.emit()

# -- Editor --
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if max_hp <= 0.0:
		warnings.append("max_hp must be greater than 0.")
	return warnings