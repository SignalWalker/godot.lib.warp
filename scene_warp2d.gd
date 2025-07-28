class_name SceneWarp2D extends Warp2D

@export var target_scene: PackedScene = null

func _ready() -> void:
	self.body_entered.connect(self._on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if Warp2D._can_warp(self, body):
		if self.target_scene == null:
			push_error("SceneWarp2D {0} has no target scene".format([self.name]))
			return

		var scn_manager := Engine.get_singleton(&"SceneManager")
		if scn_manager == null:
			push_error("SceneWarp2D could not find SceneManager singleton")
			return

		scn_manager.change_scene(self.target_scene, Warp2D.load_transition(self.transition), true, _transfer_callback(self.target_node))

static func _transfer_callback(path: NodePath) -> Callable:
	return func(scn: Node) -> void:
		if path.is_empty():
			return

		var av_node := scn.get_tree().get_first_node_in_group(&"avatar")
		if av_node == null || av_node is not Avatar:
			push_warning("no avatar found in warped-to scene")
			return

		var av := av_node as Avatar

		var trg := scn.get_node(path)
		if trg == null:
			push_error("SceneWarp2D could not find target node at {0}".format([path]))
			return
		if trg is not Node2D:
			push_error("SceneWarp2D target node is not node2d ({0}, {1})".format([path, trg]))
			return

		av.global_position = (trg as Node2D).global_position
