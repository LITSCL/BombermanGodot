extends Node2D

#1. Declarar variables globales.
@export var duracion: float

#2. Declarar variables locales.
var exploto: bool = false

#3. Zona de funciones Nodo.
func _ready() -> void:
	var posicion_grilla: Vector2 = Vector2(int(round(position.x / 16)), int(round(position.y / 16)))
	position = Vector2(posicion_grilla.x * 16, posicion_grilla.y * 16) #Cuadrando bomba dentro de una celda de la grilla.
	var nodos_raycast: Array[Node] = get_tree().get_nodes_in_group("hijo_emision_bomba")
	for nodo in nodos_raycast:
		var raycast: Node = nodo as RayCast2D
		raycast.add_exception(get_tree().get_nodes_in_group("hijo_jugador")[0]) #Evitando que los rayos colisionen con el jugador.

func _physics_process(delta) -> void:
	if (exploto):
		chequear_rayo()

#4. Zona de funciones Señal.
func _on_timer_timeout() -> void:
	$AnimationPlayer.play("bomba_explotando")

func _on_animation_player_animation_finished(nombre_animacion) -> void:
	if (nombre_animacion == "bomba_explotando"):
		exploto = true
		chequear_rayo()
		var nodos_raycast: Array[Node] = get_tree().get_nodes_in_group("hijo_emision_bomba")
		for nodo in nodos_raycast:
			var raycast: Node = nodo as RayCast2D
			raycast.remove_exception(get_tree().get_nodes_in_group("hijo_jugador")[0]) #Permitiendo que los rayos colisionen con el jugador.
		#queue_free() #Destruyendo la bomba.

#5. Zona de funciones Custom.
func chequear_rayo() -> void:
	var nodos_raycast: Array[Node] = get_tree().get_nodes_in_group("hijo_emision_bomba")
	for nodo in nodos_raycast:
		var raycast: Node = nodo as RayCast2D
		if (raycast.is_colliding): #Comprobando si el rayo colisiona con algún elemento.
			var colisionador: Node = raycast.get_collider()
			if (colisionador && colisionador.is_in_group("hijo_bloque_destructible")):
				var modificador: Vector2 = Vector2()
				if (raycast.name == "RayCast2D1"): #Abajo
					modificador.y = 16
					modificador.x = -16
				elif (raycast.name == "RayCast2D2"): #Arriba
					modificador.y = 8
					modificador.x = -16
				elif (raycast.name == "RayCast2D3"): #Izquierda
					modificador.x = -16
					modificador.y = 8
				elif (raycast.name == "RayCast2D4"): #Derecha
					modificador.x = -8
					modificador.y = 8
				else:
					pass
				var punto_colision: Vector2 = raycast.get_collision_point() + modificador #Obteniendo la posición de colisión.
				var nodo_tilemap: Node = get_tree().get_nodes_in_group("hijo_bloque_destructible")[0] as TileMap
				var posicion_tilemap: Vector2 = nodo_tilemap.local_to_map(punto_colision) #Obteniendo la posición del Tile.
				nodo_tilemap.erase_cell(0, posicion_tilemap) #Borrando el Tile.
			elif (colisionador && colisionador.is_in_group("hijo_jugador")):
				colisionador.queue_free()
			else:
				pass
