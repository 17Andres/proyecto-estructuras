
class_name ManejadorEntrada
extends Node3D



@export var camara: Camera3D

@export var grid_manager: GestorCuadricula

@export var jugador: MovimientoJugador

@export_flags_3d_physics var mascara_suelo: int = 1

@export var distancia_rayo: float = 1000.0

@export_enum("astar", "dijkstra", "dfs") var algoritmo: String = "astar"



func _ready() -> void:
	if camara == null:
		camara = get_viewport().get_camera_3d()
		if camara == null:
			push_error("[ManejadorEntrada] No se encontró una Camera3D en el viewport.")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var clic := event as InputEventMouseButton
		if clic.button_index == MOUSE_BUTTON_LEFT and clic.pressed:
			_procesar_clic(clic.position)
		elif clic.button_index == MOUSE_BUTTON_RIGHT and clic.pressed:
			if jugador.has_method("atacar"):
				jugador.atacar()



func _procesar_clic(pos_pantalla: Vector2) -> void:
	if camara == null or grid_manager == null or jugador == null:
		push_warning("[ManejadorEntrada] Faltan referencias (camara / grid_manager / jugador).")
		return

	var origen_rayo: Vector3 = camara.project_ray_origin(pos_pantalla)

	var dir_rayo: Vector3 = camara.project_ray_normal(pos_pantalla)

	var fin_rayo: Vector3 = origen_rayo + dir_rayo * distancia_rayo

	var espacio: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state

	var parametros := PhysicsRayQueryParameters3D.new()
	parametros.from           = origen_rayo
	parametros.to             = fin_rayo
	parametros.collision_mask = mascara_suelo
	parametros.exclude        = [jugador.get_rid()]

	var resultado: Dictionary = espacio.intersect_ray(parametros)

	if resultado.is_empty():
		print("[ManejadorEntrada] El rayo no impactó el suelo.")
		return

	var punto_suelo: Vector3 = resultado["position"]
	print("[ManejadorEntrada] Clic en el suelo: %s" % punto_suelo)

	var nodo_destino: Nodo = grid_manager.mundo_a_grilla(punto_suelo)

	if nodo_destino == null:
		print("[ManejadorEntrada] Clic fuera del mapa.")
		return

	if nodo_destino.es_obstaculo:
		print("[ManejadorEntrada] El destino es un obstáculo, ignorando clic.")
		return

	var pos_mago: Vector3 = jugador.global_position
	var camino: Array = []

	match algoritmo:
		"astar":
			camino = grid_manager.astar(pos_mago, punto_suelo)
		"dijkstra":
			camino = grid_manager.dijkstra(pos_mago, punto_suelo)
		"dfs":
			camino = grid_manager.dfs_camino(pos_mago, punto_suelo)
		_:
			push_warning("[ManejadorEntrada] Algoritmo desconocido: %s" % algoritmo)
			return

	if camino.is_empty():
		print("[ManejadorEntrada] No se encontró camino hacia el destino.")
	else:
		jugador.set_camino(camino)
