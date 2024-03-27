extends CharacterBody2D

#1. Declarar variables globales.
@export var velocidad_movimiento: float = 10
@export var probabilidad_cambio_direccion: float = 100

#2. Declarar constantes Enum.
enum Estados {NINGUNO, MOVIENDO_IZQUIERDA, MOVIENDO_DERECHA, MOVIENDO_ARRIBA, MOVIENDO_ABAJO, MUERTO}

#3. Declarar variables locales.
var estado_actual: Estados = Estados.MOVIENDO_DERECHA
var velocidad_movimiento_actual: Vector2 = Vector2()
var puede_moverse: bool = true
var debe_cambiar_direccion: bool = true

#4. Zona de funciones Nodo.
func _ready() -> void:
	$Sprite2D.frame = 210

func _physics_process(delta: float) -> void:
	if (estado_actual != Estados.MUERTO):
		velocidad_movimiento_actual = Vector2(0, 0)
		if (estado_actual == Estados.MOVIENDO_IZQUIERDA):
			velocidad_movimiento_actual.x = -velocidad_movimiento
			if (puede_moverse):
				$Timer.start()
				if ($Sprite2D.frame == 212):
					$Sprite2D.frame = 210
				else:
					$Sprite2D.frame+=1
			puede_moverse = false
		elif (estado_actual == Estados.MOVIENDO_DERECHA):
			velocidad_movimiento_actual.x = +velocidad_movimiento
			if (puede_moverse):
				$Timer.start()
				if ($Sprite2D.frame == 212):
					$Sprite2D.frame = 210
				else:
					$Sprite2D.frame+=1
			puede_moverse = false
		elif (estado_actual == Estados.MOVIENDO_ARRIBA):
			velocidad_movimiento_actual.y = -velocidad_movimiento
			if (puede_moverse):
				$Timer.start()
				if ($Sprite2D.frame == 212):
					$Sprite2D.frame = 210
				else:
					$Sprite2D.frame+=1
			$Sprite2D.flip_h = false
			puede_moverse = false
		elif (estado_actual == Estados.MOVIENDO_ABAJO):
			velocidad_movimiento_actual.y = +velocidad_movimiento
			if (puede_moverse):
				$Timer.start()
				if ($Sprite2D.frame == 212):
					$Sprite2D.frame = 210
				else:
					$Sprite2D.frame+=1
			$Sprite2D.flip_h = false
			puede_moverse = false
		else:
			pass
		var colision: KinematicCollision2D = move_and_collide(velocidad_movimiento_actual * delta)
		if (colision != null):
			var objeto_colisionado: Node2D = colision.get_collider()
			if (objeto_colisionado.is_in_group("hijo_pared") or objeto_colisionado.is_in_group("hijo_bloque_destructible") or objeto_colisionado.is_in_group("padre_bomba")):
				if (estado_actual == Estados.MOVIENDO_IZQUIERDA):
					cambiar_direccion(1)
				elif (estado_actual == Estados.MOVIENDO_DERECHA):
					cambiar_direccion(0)
				elif (estado_actual == Estados.MOVIENDO_ABAJO):
					cambiar_direccion(2)
				elif (estado_actual == Estados.MOVIENDO_ARRIBA):
					cambiar_direccion(3)
				else:
					pass
		else:
			var posicion_grilla: Vector2 = Vector2(int(round(position.x / 16)), int(round(position.y / 16)))
			posicion_grilla = Vector2(posicion_grilla.x * 16 - 8, posicion_grilla.y * 16 - 16) #Cuadrando el enemigo dentro de una celda de la grilla.
			if (posicion_grilla.distance_to(global_position) < 1):
				verificar_rayos()
				debe_cambiar_direccion = false
				await get_tree().create_timer(0.5).timeout
				debe_cambiar_direccion = true

#5. Zona de funciones Señal.
func _on_timer_timeout() -> void:
	puede_moverse = true

func _on_animation_player_animation_finished(nombre_animacion: String) -> void:
	if (nombre_animacion == "MUERTE"):
		$Camera2D.enabled = false
		ControladorJuego.spawn_jugador()
		queue_free()

#6. Zona de funciones Custom.
func cambiar_direccion(direccion: int) -> void:
	var probabilidad: int = randi_range(0, 100)
	if (probabilidad_cambio_direccion >= probabilidad):
		match (direccion):
			0:
				estado_actual = Estados.MOVIENDO_IZQUIERDA
				$Sprite2D.frame = 210
				$Sprite2D.flip_h = true
			1:
				estado_actual = Estados.MOVIENDO_DERECHA
				$Sprite2D.frame = 210
				$Sprite2D.flip_h = false
			2:
				estado_actual = Estados.MOVIENDO_ARRIBA
				$Sprite2D.frame = 210
			3:
				estado_actual = Estados.MOVIENDO_ABAJO
				$Sprite2D.frame = 210

func verificar_rayos() -> void:
	var nodos_raycast: Array[Node] = get_tree().get_nodes_in_group("hijo_deteccion_pared")
	for nodo in nodos_raycast:
		var raycast: Node = nodo as RayCast2D
		if (raycast.is_colliding): #Comprobando si el rayo colisiona con algún elemento.
			var colisionador: Node = raycast.get_collider()
			if (colisionador && colisionador.is_in_group("hijo_jugador")):
				pass
		else:
			if (estado_actual != Estados.MOVIENDO_DERECHA and estado_actual != Estados.MOVIENDO_IZQUIERDA and raycast.name == "RayCast2D3"): #Detectando RayCast Izquierdo.
				cambiar_direccion(0)
				return
			elif (estado_actual != Estados.MOVIENDO_IZQUIERDA and estado_actual != Estados.MOVIENDO_DERECHA and raycast.name == "RayCast2D4"): #Detectando RayCast Derecho.
				cambiar_direccion(1)
				return
			elif (estado_actual != Estados.MOVIENDO_ARRIBA and estado_actual != Estados.MOVIENDO_ABAJO and raycast.name == "RayCast2D1"): #Detectando RayCast Abajo.
				cambiar_direccion(3)
				return
			elif (estado_actual != Estados.MOVIENDO_ABAJO and estado_actual != Estados.MOVIENDO_ARRIBA and raycast.name == "RayCast2D2"): #Detectando RayCast Arriba.
				cambiar_direccion(4)
				return
			else:
				pass
	
func muerte() -> void:
	estado_actual = Estados.MUERTO
	$AnimationPlayer.play("MUERTE")
	$CollisionShape2D.disabled = true
	ControladorJuego.vidas_actuales-=1
