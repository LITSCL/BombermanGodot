extends Node2D

#1. Zona de funciones Nodo.
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_animation_player_animation_finished(nombre_animacion: String) -> void:
	queue_free()
