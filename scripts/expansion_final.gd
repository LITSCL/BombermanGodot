extends Node2D

#1. Zona de funciones Nodo.
func _ready():
	pass

func _process(delta):
	pass

func _on_animation_player_animation_finished(nombre_animacion):
	queue_free()
