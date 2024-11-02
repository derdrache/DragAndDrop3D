@tool
extends EditorPlugin

func _ready() -> void:
	add_autoload_singleton("DragAndDropGroupHelper", "res://addons/DragAndDrop3D/DragAndDropGroupHelper.gd")

func _enter_tree():
	add_custom_type(
		"DragAndDrop3D", 
		"Node3D", 
		preload("res://addons/DragAndDrop3D/nodes/drag_and_drop_3d.gd"), 
		preload("dragIcon.png")
	)
	add_custom_type(
		"DraggingObject", 
		"DraggingObject3D", 
		preload("res://addons/DragAndDrop3D/nodes/dragging_object.gd"), 
		 preload("dragIcon.png")
	)

func _exit_tree():
	remove_custom_type("DragAndDrop3D")
	remove_custom_type("DraggingObject")
