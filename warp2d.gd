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


func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Avatar:
		if self.target_node.is_empty():
			push_error("warp2d " + self.name + " has no target")
			return

		var node := self.get_node(self.target_node)
		if node == null:
			push_error("warp2d could not find target node at {0}".format([self.target_node]))
			return
		if node is not Node2D:
			push_error("warp2d target node is not node2d ({0}, {1})".format([self.target_node, node]))
			return

		var trans := load_transition(self.transition)
		# TODO :: play transition animation

		self.global_position = (node as Node2D).global_position

