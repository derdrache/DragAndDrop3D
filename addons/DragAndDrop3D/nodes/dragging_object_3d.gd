@tool
extends Node3D
class_name DraggingObject3D

signal object_body_mouse_down()

@export var heightOffset := 0.0
@export var input_ray_pickable = true:
	set(value):
		input_ray_pickable = value

var objectBody: PhysicsBody3D

func _ready() -> void:
	_check_editor_child()

	objectBody = _get_object_body()

	if objectBody: 
		objectBody.input_event.connect(_on_object_body_3d_input_event)
		objectBody.input_ray_pickable = input_ray_pickable
	
	_set_group()

func _set_group() -> void:
	if Engine.is_editor_hint(): return
	
	await get_tree().current_scene.ready
	DragAndDropGroupHelper.add_node_to_group(self, "draggingObjects")
	
func _get_object_body() -> PhysicsBody3D:
	for node in get_children():
		if node is PhysicsBody3D: return node
	
	return null	

func _on_object_body_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var button = event.button_index
		var isPressed = event.pressed
		
		if button == 1 and isPressed:
			object_body_mouse_down.emit()

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
	
	if node is PhysicsBody3D: objectBody = node
	
func _on_dragging_object_child_exiting_tree(node: Node) -> void:
	if node == objectBody: 
		objectBody = null

func _get_configuration_warnings() -> PackedStringArray:
	if objectBody is not PhysicsBody3D:
		return ["This node has no body, so you can't interact with it\n\nConsider adding a StaticBody3D, CharacterBody3D or RigigBody3D as a child to difine its body"]
	else:
		return []
