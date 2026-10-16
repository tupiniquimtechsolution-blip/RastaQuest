extends RefCounted

static func open_panel(owner_node: Node, panel_scene: PackedScene) -> CanvasLayer:
	var layer := CanvasLayer.new()
	layer.layer = 50
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	owner_node.add_child(layer)
	var panel := panel_scene.instantiate()
	panel.closed.connect(layer.queue_free)
	layer.add_child(panel)
	return layer
