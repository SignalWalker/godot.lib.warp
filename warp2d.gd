class_name Warp2D extends Area2D

@export var target_node: NodePath = NodePath(&"")
@export_custom(PROPERTY_HINT_FILE, "*.tscn", PROPERTY_USAGE_DEFAULT) var transition: String = "":
	get:
		return transition
	set(value):
		transition = value
		self._transition_node = null

var _transition_node: AnimationPlayer = null

signal warped(body: Node2D, trg: Node2D)

static func _load_transition(scn_path: String) -> AnimationPlayer:
	var scn := SceneManager.load_scene(scn_path, false, ResourceLoader.CacheMode.CACHE_MODE_REUSE)
	if scn == null:
		push_error("Warp2D could not load scene transition from path {0}".format([scn_path]))
		return null
	elif scn is AnimationPlayer:
		return scn as AnimationPlayer
	else:
		push_error("Warp2D transition is not AnimationPlayer: {0} => {1}".format([scn_path, scn]))
		return null

static func _can_warp(warp: Warp2D, node: Node2D) -> bool:
	return node.has_method(&"can_warp") && node.call(&"can_warp", warp)

func _ready() -> void:
	self.body_entered.connect(self._on_body_entered)

func _transfer(body: Node2D, trg: Node2D) -> void:
	body.global_position = trg.global_position
	if body.has_method("on_warped"):
		body.call("on_warped", self, trg)
	self.warped.emit(body, trg)

func _on_body_entered(body: Node2D) -> void:
	if self.target_node.is_empty():
		push_error("warp2d " + self.name + " has no target")
		return

	if _can_warp(self, body):
		var trg := self.get_node(self.target_node)
		if trg == null:
			push_error("warp2d could not find target node at {0}".format([self.target_node]))
			return
		if trg is not Node2D:
			push_error("warp2d target node is not node2d ({0}, {1})".format([self.target_node, trg]))
			return

		if self._transition_node == null && !self.transition.is_empty():
			self._transition_node = _load_transition(self.transition)

		if self._transition_node != null:
			SceneManager.play_transition.call_deferred(self._transition_node, true, func() -> void: self._transfer(body, trg))
		else:
			self._transfer(body, trg)
