class_name HealthCore
extends RefCounted

## This file will contain all health logic shared between HealthComponent and any future variants.
## This file does not know about the sceen tree, nodes, or signals. It only manages numbers and states.

#-- State --
var current_hp: float = 100.0
var max_hp: float = 100.0
var is_dead: bool = false 

#-- Initialization --
func initialize(p_max_hp: float) -> void: # Always call this function before using the core.
	max_hp = maxf(1.0, p_max_hp)
	current_hp = max_hp
	is_dead = false 

#-- HP Management --
func set_hp(value: float) -> float:
	current_hp = clampf(value, 0.0, max_hp)
	return current_hp

# reduce hp by amount. Amount must be a positive value.
# returns how much hp was actually lost and may be less than amount if it was close to 0 already.
func reduce_hp(amount: float) -> float:
	amount = maxf(0.0, amount)
	var before := current_hp
	current_hp = maxf(0.0,current_hp - amount)
	return before - current_hp # Actual HP lost

# Increase hp by amount. Amount must be a positive value.
# Will not exceed max_hp except allow_overheal is set to true.
# returns how much hp was actually gained
func increase_hp(amount: float, allow_overheal: bool = false) -> float:
	amount = maxf(0.0, amount)
	var before := current_hp
	var cap := max_hp if not allow_overheal else max_hp * 2.0
	current_hp = minf(current_hp + amount, cap)
	return current_hp - before # Actual HP gained

# returns hp as a frction between 0.0 and 1.0
# useful for healthbars and threshold comparison.
func get_hp_ratio() -> float:
	if max_hp <= 0.0:
		return 0.0
	return current_hp / max_hp

func is_alive() -> bool:
	return not is_dead and current_hp > 0.0

func mark_dead() -> void:
	is_dead = true
	current_hp = 0.0

func mark_alive() -> void:
	is_dead = false

func set_max_hp(new_max: float, preserve_ratio: bool = false) -> void:
	new_max = maxf(1.0, new_max)
	if preserve_ratio and max_hp > 0.0:
		var ratio := current_hp / max_hp
		max_hp = new_max
		current_hp = clampf(max_hp * ratio, 0.0, max_hp)
	else:
		max_hp = new_max
		current_hp = minf(current_hp, max_hp)