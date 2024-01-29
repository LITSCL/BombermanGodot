extends CharacterBody2D

#1. Declarar variables globales.
@export var velocidad_movimiento: float = 30

#2. Declarar constantes Enum.
enum EstadosMovimiento {NINGUNO, MOVIENDO_IZQUIERDA, MOVIENDO_DERECHA, MOVIENDO_ARRIBA, MOVIENDO_ABAJO}

#3. Declarar variables locales.
var estado_movimiento_actual: EstadosMovimiento = EstadosMovimiento.NINGUNO
var velocidad_movimiento_actual: Vector2 = Vector2()
var puede_moverse: bool = true
var puede_plantar: bool = true

#4. Zona de funciones Nodo.
func _ready() -> void:
	pass

func _physics_process(delta) -> void:
	velocidad_movimiento_actual = Vector2(0, 0)
	if (Input.is_action_pressed("tecla_a")):
		if (estado_movimiento_actual != EstadosMovimiento.MOVIENDO_IZQUIERDA):
			estado_movimiento_actual = EstadosMovimiento.MOVIENDO_IZQUIERDA
			$Sprite2D.frame = 0
		velocidad_movimiento_actual.x = -velocidad_movimiento
		if (puede_moverse):
			$Timer.start()
			if ($Sprite2D.frame == 2):
				$Sprite2D.frame = 0
			else:
				$Sprite2D.frame+=1
		$Sprite2D.flip_h = false
		puede_moverse = false
	elif (Input.is_action_pressed("tecla_d")):
		if (estado_movimiento_actual != EstadosMovimiento.MOVIENDO_DERECHA):
			estado_movimiento_actual = EstadosMovimiento.MOVIENDO_DERECHA
			$Sprite2D.frame = 0
		velocidad_movimiento_actual.x = +velocidad_movimiento
		if (puede_moverse):
			$Timer.start()
			if ($Sprite2D.frame == 2):
				$Sprite2D.frame = 0
			else:
				$Sprite2D.frame+=1
		$Sprite2D.flip_h = true
		puede_moverse = false
	elif (Input.is_action_pressed("tecla_w")):
		if (estado_movimiento_actual != EstadosMovimiento.MOVIENDO_ARRIBA):
			estado_movimiento_actual = EstadosMovimiento.MOVIENDO_ARRIBA
			$Sprite2D.frame = 17
		velocidad_movimiento_actual.y = -velocidad_movimiento
		if (puede_moverse):
			$Timer.start()
			if ($Sprite2D.frame == 19):
				$Sprite2D.frame = 17
			else:
				$Sprite2D.frame+=1
		$Sprite2D.flip_h = false
		puede_moverse = false
	elif (Input.is_action_pressed("tecla_s")):
		if (estado_movimiento_actual != EstadosMovimiento.MOVIENDO_ABAJO):
			estado_movimiento_actual = EstadosMovimiento.MOVIENDO_ABAJO
			$Sprite2D.frame = 3
		velocidad_movimiento_actual.y = +velocidad_movimiento
		if (puede_moverse):
			$Timer.start()
			if ($Sprite2D.frame == 5):
				$Sprite2D.frame = 3
			else:
				$Sprite2D.frame+=1
		$Sprite2D.flip_h = false
		puede_moverse = false
	else:
		pass
	if (Input.is_action_just_pressed("tecla_espacio") && puede_plantar):
		var nodo_main: Node = get_tree().get_nodes_in_group("main")[0] as Node2D #Obteniendo el nodo "Main".
		var nodo_nivel: Node = get_tree().get_nodes_in_group("hijo_nivel")[0] as Node2D #Obteniendo el nodo "Nivel".
		var bomba: Node = nodo_main.escena_bomba.instantiate() #Creando una instancia del nodo "Bomba".
		bomba.position = position #Asignando la posición de la bomba (Se esta asignando la posición del jugador).
		nodo_nivel.add_child(bomba) #Añadiendo como nodo hijo el nodo "Bomba" al nodo "Nivel".
		puede_plantar = false
	elif (!puede_plantar):
		chequear_bomba()
	else:
		pass
	move_and_collide(velocidad_movimiento_actual * delta)

#5. Zona de funciones Señal.
func _on_timer_timeout() -> void:
	puede_moverse = true

#6. Zona de funciones Custom.
func chequear_bomba() -> void:
	var cantidad_bombas: int = get_tree().get_nodes_in_group("padre_bomba").size() #Obteniendo la cantidad de nodos en el grupo "padre_bomba".
	if (cantidad_bombas == 0):
		puede_plantar = true
