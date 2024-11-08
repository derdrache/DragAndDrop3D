extends Node3D

signal dragging_started()
signal dragging_stopped()

@export var mousePositionDepth := 100
@export var groupExclude : Array[String] = []

@export_group("Snap")
@export_enum("Root Node Children", "Group") var sourceSnapMode := "Root Node Children"
@export var snapSourceNode: Node
@export var SnapSourceGroup: String

var _draggingObject: DraggingObject3D

func _ready() -> void:
	if not Engine.is_editor_hint(): 
		DragAndDropGroupHelper.group_added.connect(_set_dragging_object_signals)

	_set_group()
	
func _set_group() -> void:
	if Engine.is_editor_hint(): return
	
	await get_tree().current_scene.ready
	DragAndDropGroupHelper.add_node_to_group(self, "DragAndDrop3D")

func _set_dragging_object_signals(group: String, node: Node) -> void:
	if group == "draggingObjects":
		node.object_body_mouse_down.connect(set_dragging_object.bind(node))

func set_dragging_object(object: DraggingObject3D) -> void:
	_draggingObject = object
	dragging_started.emit()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if _draggingObject and event.button_index == 1 and not event.is_pressed():
			stop_drag()
	elif event is InputEventMouseMotion:
		if _draggingObject: 
			_handle_drag()
			
func stop_drag() -> void:
	_draggingObject = null
	dragging_stopped.emit()
	
func _handle_drag() -> void:
	var mousePosition3D = _get_3d_mouse_position()
	
	if not mousePosition3D: return
	
	mousePosition3D.y += _draggingObject.get_height_offset()
	_draggingObject.objectBody.global_position = mousePosition3D
	
func _get_3d_mouse_position():
	var mousePosition := get_viewport().get_mouse_position()
	var currentCamera := get_viewport().get_camera_3d()
	var params := PhysicsRayQueryParameters3D.new()
	
	params.from = currentCamera.project_ray_origin(mousePosition)
	params.to = currentCamera.project_position(mousePosition, mousePositionDepth)
	params.exclude = _get_excluded_objects()
	
	var worldspace := get_world_3d().direct_space_state
	var intersect := worldspace.intersect_ray(params)

	if not intersect: return
	
	var snapPosition = _get_snap_position(intersect.collider)
	
	if snapPosition: return snapPosition
	return intersect.position

func _get_excluded_objects() -> Array:
	var exclude := []
	
	exclude.append(_draggingObject.get_rid())
	
	for string in groupExclude:
		for node in get_tree().get_nodes_in_group(string):
			exclude.append(node.get_rid())
	
	return exclude

func _get_snap_position(object:Node):
	if sourceSnapMode == "Root Node Children" and snapSourceNode != null:
		for node in snapSourceNode.get_children():
			if object == node: return node.global_position
	elif sourceSnapMode == "Group" and object.is_in_group(SnapSourceGroup):
		return object.global_position
