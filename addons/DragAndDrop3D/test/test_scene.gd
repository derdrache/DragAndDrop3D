extends Node3D

const TEST_OBJECT_1 = preload("uid://b4srh83nbjs5j")

func _ready() -> void:
	await get_tree().create_timer(5).timeout
	var testNode = TEST_OBJECT_1.instantiate()
	add_child(testNode)
