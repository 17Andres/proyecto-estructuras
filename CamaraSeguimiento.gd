
extends Camera3D

@export var objetivo: Node3D

@export var desplazamiento: Vector3 = Vector3(0, 20, 14)

@export_range(1.0, 20.0, 0.5) var suavizado: float = 6.0


func _physics_process(delta: float) -> void:
	if objetivo == null:
		return

	var posicion_deseada: Vector3 = objetivo.global_position + desplazamiento

	global_position = global_position.lerp(posicion_deseada, suavizado * delta)

	look_at(objetivo.global_position, Vector3.UP)
