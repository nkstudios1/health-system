@tool 
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type(
		"HealthComponent", "Node", 
		preload("res://addons/health_system/nodes/health_component.gd"),
		preload("res://addons/health_system/icons/health_component.svg")
	)

func _exit_tree() -> void:
	remove_custom_type("HealthComponent")

func _get_plugin_name() -> String:
	return "Health System"