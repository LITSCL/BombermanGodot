extends Node2D

#1. Declarar variables globales.
@export var escena_jugador: PackedScene #Obteniendo la escena "Jugador" (Permite crear una instancia).
@export var escena_bomba: PackedScene #Obteniendo la escena "Bomba" (Permite crear una instancia).
@export var escena_expansion_inicial: PackedScene #Obteniendo la escena "ExpansionInicial" (Permite crear una instancia).
@export var escena_expansion_final: PackedScene #Obteniendo la escena "ExpansionFinal" (Permite crear una instancia).
@export var escena_bomba_pickup: PackedScene #Obteniendo la escena "BombaPickup" (Permite crear una instancia).
@export var escena_expansion_pickup: PackedScene #Obteniendo la escena "ExpansionPickup" (Permite crear una instancia).

#2. Zona de funciones Nodo.
func _ready() -> void:
	ControladorJuego.cargar_nivel()
	ControladorJuego.spawn_jugador()

func _physics_process(delta: float) -> void:
	pass
