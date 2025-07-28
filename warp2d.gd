class_name Warp2D extends Area2D

@export var target_node: NodePath = NodePath(&"")
@export var transition: PackedScene = null

static func load_transition(scn: PackedScene) -> AnimationPlayer:
	var trans: AnimationPlayer = null
	if scn != null:
		var inst := scn.instantiate()
		if inst is AnimationPlayer:
			trans = inst as AnimationPlayer
		else:
			push_error("warp2d transition is not AnimationPlayer: {0}".format([scn]))
	return trans

static func _can_warp(warp: Warp2D, node: Node2D) -> bool:
	return node.has_method(&"can_warp") && node.call(&"can_warp", warp)

func _ready() -> void:
	self.body_entered.connect(self._on_body_entered)

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

		var trans := load_transition(self.transition)
		# TODO :: play transition animation

		body.global_position = (trg as Node2D).global_position

