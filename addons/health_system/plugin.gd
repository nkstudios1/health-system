@tool 
extends EditorPlugin

func _enter_tree() -> void:
	print("[HealthSystem] Plugin loaded.")

func _exit_tree() -> void:
	print("[HealthSystem] Plugin unloaded.")

func _get_plugin_name() -> String:
	return "Health System"