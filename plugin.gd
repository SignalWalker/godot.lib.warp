@tool
extends EditorPlugin

func get_plugin_path() -> String:
	return (get_script() as Script).resource_path.get_base_dir()

func _enter_tree() -> void:
	if !Engine.is_editor_hint():
		return
	Engine.set_meta(&"WarpPlugin", self)

func _exit_tree() -> void:
	if !Engine.is_editor_hint():
		return
	Engine.remove_meta(&"WarpPlugin")

func _enable_plugin() -> void:
	pass

func _disable_plugin() -> void:
	pass

