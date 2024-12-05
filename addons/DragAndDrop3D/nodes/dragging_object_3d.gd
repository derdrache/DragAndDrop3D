@tool
extends Node3D
class_name DraggingObject3D

signal object_body_mouse_down()
signal dragging_started()
signal dragging_stopped()

@export var heightOffset := 0.0
@export var input_ray_pickable := true:
	set(value):
		input_ray_pickable = value

var objectBody: CollisionObject3D
var snapPosition: Vector3

func _ready() -> void:
	_check_editor_child()

	objectBody = _get_object_body()

	if objectBody: 
		objectBody.input_event.connect(_on_object_body_3d_input_event)
		objectBody.input_ray_pickable = input_ray_pickable
	
	_set_group()
	
	
	if not Engine.is_editor_hint(): 
		_set_default_snap_position()
		_set_late_signals()

func _set_group() -> void:
	if Engine.is_editor_hint(): return
	
	await get_tree().current_scene.ready
	DragAndDropGroupHelper.add_node_to_group(self, "draggingObjects")

func _set_default_snap_position() -> void:
	await get_tree().physics_frame
	snapPosition = Vector3(global_position.x, global_position.y - get_height_offset() , global_position.z)

func _set_late_signals() -> void:
	await get_tree().current_scene.ready
	
	var dragAndDrop3D: DragAndDrop3D = get_tree().get_first_node_in_group("DragAndDrop3D")
	dragAndDrop3D.dragging_started.connect(_is_dragging.bind(true))
	dragAndDrop3D.dragging_stopped.connect(_is_dragging.bind(false))
	
func _get_object_body() -> CollisionObject3D:
	for node in get_children():
		if node is CollisionObject3D: return node
	
	return null	

func _is_dragging(draggingObject, boolean) -> void:
	if not draggingObject == self: return
	
	if boolean: dragging_started.emit()
	else: dragging_stopped.emit()

func _on_object_body_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var leftClicked = event.button_index == 1 and event.is_pressed()
		
		if leftClicked: object_body_mouse_down.emit()

func get_rid() -> RID:
	return objectBody.get_rid()
	
func get_height_offset() -> float:
	return heightOffset
	
#Editor Settings
func _check_editor_child() -> void:
	if not Engine.is_editor_hint(): return
	
	child_entered_tree.connect(_on_dragging_object_child_entered_tree)
	child_exiting_tree.connect(_on_dragging_object_child_exiting_tree)	

func _on_dragging_object_child_entered_tree(node: Node) -> void:
	if objectBody: return
	
	if node is CollisionObject3D: 
		objectBody = node
			
func _on_dragging_object_child_exiting_tree(node: Node) -> void:
	if node == objectBody: 
		objectBody = null

func _get_configuration_warnings() -> PackedStringArray:
	if objectBody is not CollisionObject3D:
		return ["This node has no CollisionObject, so you can't interact with it\n\nConsider adding a StaticBody3D, CharacterBody3D, RigigBody3D or Area3D as a child to difine its body"]
	else:
		return []
