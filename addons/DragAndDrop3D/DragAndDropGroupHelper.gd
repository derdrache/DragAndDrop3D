extends Node3D

signal group_added(group, node)
signal group_exited(group, node)

static func add_node_to_group(node: Node, group: String) -> void:
	node.add_to_group(group)
	DragAndDropGroupHelper.group_added.emit(group, node)

static func remove_node_from_group(node: Node, group: String) -> void:
	node.remove_from_group(group)
	DragAndDropGroupHelper.group_exited.emit(group, node)
