extends Node2D

#1. Zona de funciones Nodo.
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_area_2d_body_entered(cuerpo: Node) -> void:
	if (cuerpo.is_in_group("hijo_jugador")):
		var nodo_jugador: Node = get_tree().get_nodes_in_group("hijo_jugador")[0]
		nodo_jugador.bombas+=1
		queue_free()
