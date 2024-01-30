extends Node2D

#1. Declarar variables locales.
var vidas_actuales: int = 3
var nivel_actual: int = 1

#2. Zona de funciones Nodo.
func _ready() -> void:
	pass

#3. Zona de funciones Custom.
func spawn_jugador() -> void:
	if (vidas_actuales > 0):
		var nodo_main: Node = get_tree().get_nodes_in_group("main")[0] as Node2D #Obteniendo el nodo "Main".
		var nodo_nivel: Node = get_tree().get_nodes_in_group("hijo_nivel")[0] as Node2D #Obteniendo el nodo "Nivel".
		var nodo_spawn_jugador: Node = get_tree().get_nodes_in_group("hijo_spawn_jugador")[0] as Node2D #Obteniendo el nodo "SpawnJugador".
		var jugador: Node = nodo_main.escena_jugador.instantiate() #Creando una instancia de la escena "Jugador".
		jugador.position = nodo_spawn_jugador.position #Modificando la posición del jugador.
		jugador.position.x = 0 #TODO: Borrar.
		jugador.position.y = 0 #TODO: Borrar.
		nodo_nivel.add_child(jugador) #Añadiendo en nodo Jugador al nodo Nivel.

func cargar_nivel() -> void:
	var nodo_main: Node = get_tree().get_nodes_in_group("main")[0] as Node2D #Obteniendo el nodo "Main".
	var ruta_nivel: Resource = load("res://scenes/nivel_" + str(nivel_actual) + ".tscn")
	var nivel: Node = ruta_nivel.instantiate() #Creando una instancia de la escena "Nivel_X".
	nodo_main.add_child(nivel)
