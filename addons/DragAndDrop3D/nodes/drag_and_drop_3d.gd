@tool
extends Node3D

signal dragging_started()
signal dragging_stopped()

@export var mousePositionDepth := 100
@export var groupExclude : Array[String] = []
@export_flags_3d_physics var collisionMask: int = 1

@export_group("Snap")
@export var useSnap := false:
	set(value):
		useSnap = value
		notify_property_list_changed()
@export_enum("Node Children", "Group") var sourceSnapMode := "Node Children":
	set(value):
		sourceSnapMode = value
		notify_property_list_changed()
@export var snapSourceNode: Node
@export var SnapSourceGroup: String
## If [code]true[/code], you swap the dragging objects if the snap position is already taken[br]
## So your drag Object will take the place and the object that was previously in the place becomes the drag object[br][br]
## Only works if the object to be replaced has already been moved 
@export var swapDraggingObjects := false

var _draggingObject: DraggingObject3D
var _otherObjectOnPosition: DraggingObject3D

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
	var swaped = _swap_dragging_objects()
	
	if swaped: return
	
	_draggingObject = null
	dragging_stopped.emit()
	
func _handle_drag() -> void:
	var mousePosition3D = _get_3d_mouse_position()
	if useSnap: _draggingObject.snapPosition = mousePosition3D
	
	if not mousePosition3D: return
	
	mousePosition3D.y += _draggingObject.get_height_offset()
	_draggingObject.objectBody.global_position = mousePosition3D
	
func _get_3d_mouse_position():
	var mousePosition := get_viewport().get_mouse_position()
	var currentCamera := get_viewport().get_camera_3d()
	var params := PhysicsRayQueryParameters3D.new()
	
	params.from = currentCamera.project_ray_origin(mousePosition)
	params.to = currentCamera.project_position(mousePosition, mousePositionDepth)
	params.collide_with_areas = true
	params.exclude = _get_excluded_objects()
	params.set_collision_mask(collisionMask)
	
	var worldspace := get_world_3d().direct_space_state
	var intersect := worldspace.intersect_ray(params)

	if not intersect: return

	if intersect.collider.get_parent() is DraggingObject3D: _otherObjectOnPosition = intersect.collider.get_parent()
	else: _otherObjectOnPosition = null
	
	var snapPosition = _get_snap_position(intersect.collider)
	
	var newPosition
	if snapPosition: newPosition =  snapPosition
	else: newPosition = intersect.position
	
	return newPosition

func _get_excluded_objects() -> Array:
	var exclude := []
	
	exclude.append(_draggingObject.get_rid())
	
	for string in groupExclude:
		for node in get_tree().get_nodes_in_group(string):
			exclude.append(node.get_rid())
	
	return exclude

func _get_snap_position(collider:Node):
	if not useSnap: return
	
	if sourceSnapMode == "Node Children" and snapSourceNode != null:
		for node in snapSourceNode.get_children():
			if collider == node: 
				return node.global_position
	elif sourceSnapMode == "Group" and collider.is_in_group(SnapSourceGroup):
		return collider.global_position

func _swap_dragging_objects() -> bool:
	if (not swapDraggingObjects or 
		not _otherObjectOnPosition or 
		_otherObjectOnPosition.snapPosition == null): return false
	
	var position = _otherObjectOnPosition.snapPosition
	position.y += _draggingObject.get_height_offset()
	_draggingObject.objectBody.global_position = position
	
	_draggingObject = _otherObjectOnPosition
	_otherObjectOnPosition = null

	return true
	
			
	

func _validate_property(property: Dictionary) -> void:
	var hideList = []
	
	hideList += _editor_snap_validate()
		
	if property.name in hideList: 
		property.usage = PROPERTY_USAGE_NO_EDITOR 

func _editor_snap_validate() -> Array:
	var list = []
	
	if not useSnap:
		list.append("sourceSnapMode")
		list.append("SnapSourceGroup")
		list.append("snapSourceNode")
	
	if useSnap:
		if sourceSnapMode == "Node Children":
			list.append("SnapSourceGroup")
		else:
			list.append("snapSourceNode")
			
	return list
