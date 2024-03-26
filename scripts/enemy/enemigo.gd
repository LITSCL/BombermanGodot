extends CharacterBody2D

#1. Declarar variables globales.
@export var velocidad_movimiento: float = 10

#2. Declarar constantes Enum.
enum Estados {NINGUNO, MOVIENDO_IZQUIERDA, MOVIENDO_DERECHA, MOVIENDO_ARRIBA, MOVIENDO_ABAJO, MUERTO}

#3. Declarar variables locales.
var estado_actual: Estados = Estados.MOVIENDO_DERECHA
var velocidad_movimiento_actual: Vector2 = Vector2()
var puede_moverse: bool = true

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
		
func muerte() -> void:
	estado_actual = Estados.MUERTO
	$AnimationPlayer.play("MUERTE")
	$CollisionShape2D.disabled = true
	ControladorJuego.vidas_actuales-=1
