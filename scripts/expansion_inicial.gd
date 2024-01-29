extends Node2D

#1. Zona de funciones Nodo.
func _ready() -> void:
	pass

func _process(delta) -> void:
	pass

func _on_animation_player_animation_finished(nombre_animacion) -> void:
	queue_free()
