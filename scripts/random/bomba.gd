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

func _physics_process(delta: float) -> void:
	if (exploto):
		verificar_rayos()
		queue_free() #Destruyendo la bomba.

#4. Zona de funciones Señal.
func _on_timer_timeout() -> void:
	$AnimationPlayer.play("BOMBA_EXPLOTANDO")
	generar_expansion()

func _on_animation_player_animation_finished(nombre_animacion: String) -> void:
	if (nombre_animacion == "BOMBA_EXPLOTANDO"):
		exploto = true
		verificar_rayos()
		var nodos_raycast: Array[Node] = get_tree().get_nodes_in_group("hijo_emision_bomba")
		for nodo in nodos_raycast:
			var raycast: Node = nodo as RayCast2D
			raycast.remove_exception(get_tree().get_nodes_in_group("hijo_jugador")[0]) #Permitiendo que los rayos colisionen con el jugador.

#5. Zona de funciones Custom.
func verificar_rayos() -> void:
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
				colisionador.muerte();
			else:
				pass

func generar_expansion() -> void:
	var nodo_nivel: Node = get_tree().get_nodes_in_group("hijo_nivel")[0] as Node2D
	var casillero_actual: int = 1
	var casillero_recorrer: int = -1
	#EXPANSIÓN DERECHA.
	casillero_recorrer = $RayCast2D4.target_position.y / 16
	for i in casillero_recorrer:
		if (casillero_actual < casillero_recorrer):
			var casillero_final: int = position.x + casillero_actual * 16
			if (!$RayCast2D4.is_colliding() || ($RayCast2D4.is_colliding() && $RayCast2D4.get_collision_point().x + 8 > casillero_final)):
				var nodo_main: Node = get_tree().get_nodes_in_group("main")[0] as Node2D #Obteniendo el nodo "Main".
				var expansion_inicial: Node = nodo_main.escena_expansion_inicial.instantiate() #Creando una instancia de la escena "ExpansionInicial".
				nodo_nivel.add_child(expansion_inicial)
				expansion_inicial.position = Vector2(position.x + casillero_actual * 16, position.y)
		elif (casillero_actual == casillero_recorrer && !$RayCast2D4.is_colliding()):
			var nodo_main: Node = get_tree().get_nodes_in_group("main")[0] as Node2D #Obteniendo el nodo "Main".
			var expansion_final: Node = nodo_main.escena_expansion_final.instantiate() #Creando una instancia de la escena "ExpansionFinal".
			nodo_nivel.add_child(expansion_final)
			expansion_final.position = Vector2(position.x + casillero_actual * 16, position.y)
		else:
			pass
		casillero_actual+=1
	casillero_actual = 1
	#EXPANSIÓN IZQUIERDA.
	casillero_recorrer = $RayCast2D3.target_position.y / 16
	for i in casillero_recorrer:
		if (casillero_actual < casillero_recorrer):
			var casillero_final: int = position.x + casillero_actual * 16
			if (!$RayCast2D3.is_colliding() || ($RayCast2D3.is_colliding() && $RayCast2D3.get_collision_point().x - 8 > casillero_final)):
				var nodo_main: Node = get_tree().get_nodes_in_group("main")[0] as Node2D #Obteniendo el nodo "Main".
				var expansion_inicial: Node = nodo_main.escena_expansion_inicial.instantiate() #Creando una instancia de la escena "ExpansionInicial".
				nodo_nivel.add_child(expansion_inicial)
				expansion_inicial.position = Vector2(position.x - casillero_actual * 16, position.y)
				expansion_inicial.get_node("Sprite2D").flip_h = true #Volteando horizontalmente el Sprite.
		elif (casillero_actual == casillero_recorrer && !$RayCast2D3.is_colliding()):
			var nodo_main: Node = get_tree().get_nodes_in_group("main")[0] as Node2D #Obteniendo el nodo "Main".
			var expansion_final: Node = nodo_main.escena_expansion_final.instantiate() #Creando una instancia de la escena "ExpansionFinal".
			nodo_nivel.add_child(expansion_final)
			expansion_final.position = Vector2(position.x - casillero_actual * 16, position.y)
			expansion_final.get_node("Sprite2D").flip_h = true #Volteando horizontalmente el Sprite.
		else:
			pass
		casillero_actual+=1
	casillero_actual = 1
	#EXPANSIÓN ARRIBA.
	casillero_recorrer = $RayCast2D2.target_position.y / 16
	for i in casillero_recorrer:
		if (casillero_actual < casillero_recorrer):
			var casillero_final: int = position.x + casillero_actual * 16
			if (!$RayCast2D2.is_colliding() || ($RayCast2D2.is_colliding() && $RayCast2D2.get_collision_point().y - 8 > casillero_final)):
				var nodo_main: Node = get_tree().get_nodes_in_group("main")[0] as Node2D #Obteniendo el nodo "Main".
				var expansion_inicial: Node = nodo_main.escena_expansion_inicial.instantiate() #Creando una instancia de la escena "ExpansionInicial".
				nodo_nivel.add_child(expansion_inicial)
				expansion_inicial.position = Vector2(position.x, position.y - casillero_actual * 16)
				expansion_inicial.get_node("Sprite2D").rotation_degrees = 270 #Rotando el Sprite.
		elif (casillero_actual == casillero_recorrer && !$RayCast2D2.is_colliding()):
			var nodo_main: Node = get_tree().get_nodes_in_group("main")[0] as Node2D #Obteniendo el nodo "Main".
			var expansion_final: Node = nodo_main.escena_expansion_final.instantiate() #Creando una instancia de la escena "ExpansionFinal".
			nodo_nivel.add_child(expansion_final)
			expansion_final.position = Vector2(position.x, position.y - casillero_actual * 16)
			expansion_final.get_node("Sprite2D").rotation_degrees = 270 #Rotando el Sprite.
		else:
			pass
		casillero_actual+=1
	casillero_actual = 1
	#EXPANSIÓN ABAJO.
	casillero_recorrer = $RayCast2D1.target_position.y / 16
	for i in casillero_recorrer:
		if (casillero_actual < casillero_recorrer):
			var casillero_final: int = position.x + casillero_actual * 16
			if (!$RayCast2D1.is_colliding() || ($RayCast2D1.is_colliding() && $RayCast2D1.get_collision_point().y + 8 > casillero_final)):
				var nodo_main: Node = get_tree().get_nodes_in_group("main")[0] as Node2D #Obteniendo el nodo "Main".
				var expansion_inicial: Node = nodo_main.escena_expansion_inicial.instantiate() #Creando una instancia de la escena "ExpansionInicial".
				nodo_nivel.add_child(expansion_inicial)
				expansion_inicial.position = Vector2(position.x, position.y + casillero_actual * 16)
				expansion_inicial.get_node("Sprite2D").rotation_degrees = 90 #Rotando el Sprite.
		elif (casillero_actual == casillero_recorrer && !$RayCast2D1.is_colliding()):
			var nodo_main: Node = get_tree().get_nodes_in_group("main")[0] as Node2D #Obteniendo el nodo "Main".
			var expansion_final: Node = nodo_main.escena_expansion_final.instantiate() #Creando una instancia de la escena "ExpansionFinal".
			nodo_nivel.add_child(expansion_final)
			expansion_final.position = Vector2(position.x, position.y + casillero_actual * 16)
			expansion_final.get_node("Sprite2D").rotation_degrees = 90 #Rotando el Sprite.
		else:
			pass
		casillero_actual+=1
