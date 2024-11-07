@tool
extends EditorPlugin

func _ready() -> void:
	add_autoload_singleton("DragAndDropGroupHelper", "res://addons/DragAndDrop3D/DragAndDropGroupHelper.gd")

func _enter_tree():
	add_custom_type(
		"DragAndDrop3D", 
		"Node3D", 
		preload("res://addons/DragAndDrop3D/nodes/drag_and_drop_3d.gd"), 
		preload("res://addons/DragAndDrop3D/assets/dragIcon.png")
	)
	add_custom_type(
		"DraggingObject3D", 
		"Node3D", 
		preload("res://addons/DragAndDrop3D/nodes/dragging_object_3d.gd"), 
		preload("res://addons/DragAndDrop3D/assets/dragIcon.png")
	)

func _exit_tree():
	remove_custom_type("DragAndDrop3D")
	remove_custom_type("DraggingObject")
