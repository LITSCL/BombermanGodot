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
		var nodo_jugador: Node = get_tree().get_nodes_in_group("hijo_jugador")[0]
		raycast.add_exception(nodo_jugador) #Evitando que los rayos colisionen con el jugador.
		raycast.target_position.y = 16 * nodo_jugador.expansor
		
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
			var nodo_jugador: Node = get_tree().get_nodes_in_group("hijo_jugador")[0]
			raycast.remove_exception(nodo_jugador) #Permitiendo que los rayos colisionen con el jugador.

#5. Zona de funciones Custom.
func verificar_rayos() -> void:
	var nodos_raycast: Array[Node] = get_tree().get_nodes_in_group("hijo_emision_bomba")
	for nodo in nodos_raycast:
		var raycast: Node = nodo as RayCast2D
		if (raycast.is_colliding): #Comprobando si el rayo colisiona con algún elemento.
			var colisionador: Node = raycast.get_collider()
			if (colisionador && colisionador.is_in_group("hijo_bloque_destructible")):
				var modificador: Vector2 = Vector2()
				if (raycast.name == "AbajoRayCast2D"):
					modificador.y = 16
					modificador.x = -16
				elif (raycast.name == "ArribaRayCast2D"): 
					modificador.y = 8
					modificador.x = -16
				elif (raycast.name == "IzquierdaRayCast2D"):
					modificador.x = -16
					modificador.y = 8
				elif (raycast.name == "DerechaRayCast2D"):
					modificador.x = -8
					modificador.y = 8
				else:
					pass
				var punto_colision: Vector2 = raycast.get_collision_point() + modificador #Obteniendo la posición de colisión.
				var nodo_tilemap: Node = get_tree().get_nodes_in_group("hijo_bloque_destructible")[0] as TileMap
				var posicion_tilemap: Vector2 = nodo_tilemap.local_to_map(punto_colision) #Obteniendo la posición del Tile.
				if (nodo_tilemap.get_cell_atlas_coords(0, posicion_tilemap) == Vector2i(1, 13)): #Comprobando que el Tile corresponda al de una bomba en Atlas.
					var nodo_main: Node = get_tree().get_nodes_in_group("main")[0] as Node2D #Obteniendo el nodo "Main".
					var nodo_nivel_1: Node = get_tree().get_nodes_in_group("padre_nivel")[0] as Node2D
					var bomba_pickup: Node = nodo_main.escena_bomba_pickup.instantiate() #Creando una instancia de la escena "BombaPickup".
					bomba_pickup.position = punto_colision + modificador
					bomba_pickup.position.y-=24
					bomba_pickup.position.x+=32
					nodo_nivel_1.add_child(bomba_pickup) #Añadiendo como nodo hijo el nodo "BombaPickup" al nodo "Nivel".
				elif (false): #Comprobando que el Tile corresponda al de una expansión en Atlas.
					var nodo_main: Node = get_tree().get_nodes_in_group("main")[0] as Node2D #Obteniendo el nodo "Main".
					var nodo_nivel_1: Node = get_tree().get_nodes_in_group("padre_nivel")[0] as Node2D
					var expansion_pickup: Node = nodo_main.escena_expansion_pickup.instantiate() #Creando una instancia de la escena "ExpansionPickup".
					expansion_pickup.position = punto_colision + modificador
					expansion_pickup.position.y-=24
					expansion_pickup.position.x+=32
					nodo_nivel_1.add_child(expansion_pickup) #Añadiendo como nodo hijo el nodo "ExpansionPickup" al nodo "Nivel".
				else:
					pass
				nodo_tilemap.erase_cell(0, posicion_tilemap) #Borrando el Tile.
			elif (colisionador && colisionador.is_in_group("hijo_jugador")):
				colisionador.muerte();
			else:
				pass

func generar_expansion() -> void:
	var nodo_nivel: Node = get_tree().get_nodes_in_group("padre_nivel")[0] as Node2D
	var casillero_actual: int = 1
	var casillero_recorrer: int = -1
	#EXPANSIÓN DERECHA.
	casillero_recorrer = $DerechaRayCast2D.target_position.y / 16
	for i in casillero_recorrer:
		if (casillero_actual < casillero_recorrer):
			var casillero_final: int = position.x + casillero_actual * 16
			if (!$DerechaRayCast2D.is_colliding() || ($DerechaRayCast2D.is_colliding() && $DerechaRayCast2D.get_collision_point().x + 8 > casillero_final)):
				var nodo_main: Node = get_tree().get_nodes_in_group("main")[0] as Node2D #Obteniendo el nodo "Main".
				var expansion_inicial: Node = nodo_main.escena_expansion_inicial.instantiate() #Creando una instancia de la escena "ExpansionInicial".
				nodo_nivel.add_child(expansion_inicial)
				expansion_inicial.position = Vector2(position.x + casillero_actual * 16, position.y)
		elif (casillero_actual == casillero_recorrer && !$DerechaRayCast2D.is_colliding()):
			var nodo_main: Node = get_tree().get_nodes_in_group("main")[0] as Node2D #Obteniendo el nodo "Main".
			var expansion_final: Node = nodo_main.escena_expansion_final.instantiate() #Creando una instancia de la escena "ExpansionFinal".
			nodo_nivel.add_child(expansion_final)
			expansion_final.position = Vector2(position.x + casillero_actual * 16, position.y)
		else:
			pass
		casillero_actual+=1
	casillero_actual = 1
	#EXPANSIÓN IZQUIERDA.
	casillero_recorrer = $IzquierdaRayCast2D.target_position.y / 16
	for i in casillero_recorrer:
		if (casillero_actual < casillero_recorrer):
			var casillero_final: int = position.x + casillero_actual * 16
			if (!$IzquierdaRayCast2D.is_colliding() || ($IzquierdaRayCast2D.is_colliding() && $IzquierdaRayCast2D.get_collision_point().x - 8 > casillero_final)):
				var nodo_main: Node = get_tree().get_nodes_in_group("main")[0] as Node2D #Obteniendo el nodo "Main".
				var expansion_inicial: Node = nodo_main.escena_expansion_inicial.instantiate() #Creando una instancia de la escena "ExpansionInicial".
				nodo_nivel.add_child(expansion_inicial)
				expansion_inicial.position = Vector2(position.x - casillero_actual * 16, position.y)
				expansion_inicial.get_node("Sprite2D").flip_h = true #Volteando horizontalmente el Sprite.
		elif (casillero_actual == casillero_recorrer && !$IzquierdaRayCast2D.is_colliding()):
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
	casillero_recorrer = $ArribaRayCast2D.target_position.y / 16
	for i in casillero_recorrer:
		if (casillero_actual < casillero_recorrer):
			var casillero_final: int = position.x + casillero_actual * 16
			if (!$ArribaRayCast2D.is_colliding() || ($ArribaRayCast2D.is_colliding() && $ArribaRayCast2D.get_collision_point().y - 8 > casillero_final)):
				var nodo_main: Node = get_tree().get_nodes_in_group("main")[0] as Node2D #Obteniendo el nodo "Main".
				var expansion_inicial: Node = nodo_main.escena_expansion_inicial.instantiate() #Creando una instancia de la escena "ExpansionInicial".
				nodo_nivel.add_child(expansion_inicial)
				expansion_inicial.position = Vector2(position.x, position.y - casillero_actual * 16)
				expansion_inicial.get_node("Sprite2D").rotation_degrees = 270 #Rotando el Sprite.
		elif (casillero_actual == casillero_recorrer && !$ArribaRayCast2D.is_colliding()):
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
	casillero_recorrer = $AbajoRayCast2D.target_position.y / 16
	for i in casillero_recorrer:
		if (casillero_actual < casillero_recorrer):
			var casillero_final: int = position.x + casillero_actual * 16
			if (!$AbajoRayCast2D.is_colliding() || ($AbajoRayCast2D.is_colliding() && $AbajoRayCast2D.get_collision_point().y + 8 > casillero_final)):
				var nodo_main: Node = get_tree().get_nodes_in_group("main")[0] as Node2D #Obteniendo el nodo "Main".
				var expansion_inicial: Node = nodo_main.escena_expansion_inicial.instantiate() #Creando una instancia de la escena "ExpansionInicial".
				nodo_nivel.add_child(expansion_inicial)
				expansion_inicial.position = Vector2(position.x, position.y + casillero_actual * 16)
				expansion_inicial.get_node("Sprite2D").rotation_degrees = 90 #Rotando el Sprite.
		elif (casillero_actual == casillero_recorrer && !$AbajoRayCast2D.is_colliding()):
			var nodo_main: Node = get_tree().get_nodes_in_group("main")[0] as Node2D #Obteniendo el nodo "Main".
			var expansion_final: Node = nodo_main.escena_expansion_final.instantiate() #Creando una instancia de la escena "ExpansionFinal".
			nodo_nivel.add_child(expansion_final)
			expansion_final.position = Vector2(position.x, position.y + casillero_actual * 16)
			expansion_final.get_node("Sprite2D").rotation_degrees = 90 #Rotando el Sprite.
		else:
			pass
		casillero_actual+=1
