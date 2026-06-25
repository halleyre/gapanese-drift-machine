extends Area2D

@warning_ignore("unused_parameter")

func _on_body_entered(body: Node2D) -> void:
	print("Yummy")
	queue_free()
