
class_name GestorCuadricula
extends Node3D



@export var ancho: int = 100

@export var alto: int = 100

@export var tamano_celda: float = 2.0

@export var origen_mapa: Vector3 = Vector3.ZERO

@export var altura_raycast: float = 10.0

@export_flags_3d_physics var mascara_obstaculos: int = 1



var grilla: Dictionary = {}

const TOLERANCIA_LLEGADA: float = 0.2



func _ready() -> void:
	generar_mapa()
	await get_tree().physics_frame
	inicializar_grilla()



func generar_mapa() -> void:
	grilla.clear()

	for fila in range(alto):          
		for col in range(ancho):      
			var coord := Vector2i(col, fila)

			var pos := Vector3(
				origen_mapa.x + col * tamano_celda + tamano_celda * 0.5,
				origen_mapa.y,
				origen_mapa.z + fila * tamano_celda + tamano_celda * 0.5
			)

			grilla[coord] = Nodo.new(coord, pos, false)

	print("[GestorCuadricula] Mapa generado: %d x %d = %d nodos" % [ancho, alto, grilla.size()])



func inicializar_grilla() -> void:
	var espacio: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state

	var parametros := PhysicsRayQueryParameters3D.new()
	parametros.collision_mask = mascara_obstaculos   
	parametros.hit_back_faces = false

	var obstaculos_encontrados: int = 0

	for coord: Vector2i in grilla.keys():
		var nodo: Nodo = grilla[coord]

		var origen := Vector3(nodo.posicion_mundo.x, altura_raycast, nodo.posicion_mundo.z)
		var destino := Vector3(nodo.posicion_mundo.x, origen_mapa.y - 0.1, nodo.posicion_mundo.z)

		parametros.from = origen
		parametros.to   = destino

		var resultado: Dictionary = espacio.intersect_ray(parametros)

		if resultado.size() > 0:
			var objeto_golpeado: Object = resultado["collider"]

			if objeto_golpeado is Node and objeto_golpeado.is_in_group("obstaculos"):
				nodo.es_obstaculo = true
				obstaculos_encontrados += 1

	print("[GestorCuadricula] Obstáculos detectados: %d" % obstaculos_encontrados)


func marcar_obstaculo(coord: Vector2i) -> void:
	if grilla.has(coord):
		grilla[coord].es_obstaculo = true


func mundo_a_grilla(pos: Vector3) -> Nodo:
	var col := int((pos.x - origen_mapa.x) / tamano_celda)
	var fila := int((pos.z - origen_mapa.z) / tamano_celda)
	var coord := Vector2i(col, fila)
	return grilla.get(coord, null)



func obtener_vecinos(nodo: Nodo) -> Array:
	var vecinos: Array = []

	var direcciones := [
		Vector2i( 0, -1),   
		Vector2i( 0,  1),   
		Vector2i( 1,  0),   
		Vector2i(-1,  0),   
		Vector2i( 1, -1),   
		Vector2i(-1, -1),   
		Vector2i( 1,  1),   
		Vector2i(-1,  1),   
	]

	for dir: Vector2i in direcciones:
		var coord_vecino: Vector2i = nodo.coordenada + dir

		if coord_vecino.x < 0 or coord_vecino.x >= ancho:
			continue
		if coord_vecino.y < 0 or coord_vecino.y >= alto:
			continue

		var vecino: Nodo = grilla[coord_vecino]

		if not vecino.es_obstaculo:
			vecinos.append(vecino)

	return vecinos



func _heuristica(a: Nodo, b: Nodo) -> float:
	var dx := float(abs(a.coordenada.x - b.coordenada.x))
	var dz := float(abs(a.coordenada.y - b.coordenada.y))
	return sqrt(dx * dx + dz * dz)


func _insertar_ordenado(lista: Array, nodo: Nodo) -> void:
	var i := 0
	while i < lista.size() and lista[i].f_cost <= nodo.f_cost:
		i += 1
	lista.insert(i, nodo)


func astar(inicio_pos: Vector3, fin_pos: Vector3) -> Array[Vector3]:
	var nodo_inicio: Nodo = mundo_a_grilla(inicio_pos)
	var nodo_fin:    Nodo = mundo_a_grilla(fin_pos)

	if nodo_inicio == null or nodo_fin == null:
		push_warning("[A*] Posición fuera del mapa.")
		return []
	if nodo_fin.es_obstaculo:
		push_warning("[A*] El destino es un obstáculo.")
		return []

	for nodo in grilla.values():
		nodo.resetear()

	nodo_inicio.g_cost = 0.0
	nodo_inicio.h_cost = _heuristica(nodo_inicio, nodo_fin)

	var open_set: Array = []
	_insertar_ordenado(open_set, nodo_inicio)

	var closed_set: Dictionary = {}

	var iteraciones := 0
	var MAX_ITERACIONES := 1000

	while open_set.size() > 0:
		iteraciones += 1
		if iteraciones > MAX_ITERACIONES:
			push_warning("[A*] Límite de iteraciones excedido. Camino demasiado complejo o inalcanzable.")
			return []

		var actual: Nodo = open_set.pop_front()

		closed_set[actual.coordenada] = true

		if actual.coordenada == nodo_fin.coordenada:
			return _reconstruir_camino(nodo_fin)

		for vecino in obtener_vecinos(actual):

			if closed_set.has(vecino.coordenada):
				continue

			var es_diagonal: bool = (vecino.coordenada.x != actual.coordenada.x and
									 vecino.coordenada.y != actual.coordenada.y)
			var costo_paso: float = 1.414 if es_diagonal else 1.0
			var nuevo_g: float = actual.g_cost + costo_paso

			if nuevo_g < vecino.g_cost:
				vecino.g_cost = nuevo_g
				vecino.h_cost = _heuristica(vecino, nodo_fin)
				vecino.padre  = actual

				var idx := open_set.find(vecino)
				if idx != -1:
					open_set.remove_at(idx)

				_insertar_ordenado(open_set, vecino)

	push_warning("[A*] No se encontró camino.")
	return []


func _reconstruir_camino(nodo_fin: Nodo) -> Array[Vector3]:
	var camino: Array[Vector3] = []
	var actual: Nodo = nodo_fin

	while actual != null:
		camino.push_front(actual.posicion_mundo)  
		actual = actual.padre

	print("[A*] Camino encontrado: %d pasos." % camino.size())
	return camino



func dijkstra(inicio_pos: Vector3, fin_pos: Vector3) -> Array[Vector3]:
	var nodo_inicio: Nodo = mundo_a_grilla(inicio_pos)
	var nodo_fin:    Nodo = mundo_a_grilla(fin_pos)

	if nodo_inicio == null or nodo_fin == null:
		push_warning("[Dijkstra] Posición fuera del mapa.")
		return []
	if nodo_fin.es_obstaculo:
		push_warning("[Dijkstra] El destino es un obstáculo.")
		return []

	for nodo in grilla.values():
		nodo.resetear()

	nodo_inicio.g_cost = 0.0

	var open_set: Array = []
	_insertar_ordenado(open_set, nodo_inicio)

	var closed_set: Dictionary = {}

	var iteraciones := 0
	var MAX_ITERACIONES := 1000

	while open_set.size() > 0:
		iteraciones += 1
		if iteraciones > MAX_ITERACIONES:
			push_warning("[Dijkstra] Límite de iteraciones excedido. Camino demasiado complejo o inalcanzable.")
			return []

		var actual: Nodo = open_set.pop_front()

		if closed_set.has(actual.coordenada):
			continue
		closed_set[actual.coordenada] = true

		if actual.coordenada == nodo_fin.coordenada:
			return _reconstruir_camino(nodo_fin)

		for vecino in obtener_vecinos(actual):
			if closed_set.has(vecino.coordenada):
				continue

			var es_diagonal: bool = (vecino.coordenada.x != actual.coordenada.x and
									 vecino.coordenada.y != actual.coordenada.y)
			var costo_paso: float = 1.414 if es_diagonal else 1.0
			var nuevo_g: float = actual.g_cost + costo_paso

			if nuevo_g < vecino.g_cost:
				vecino.g_cost = nuevo_g
				vecino.h_cost = 0.0   
				vecino.padre  = actual

				var idx := open_set.find(vecino)
				if idx != -1:
					open_set.remove_at(idx)
				_insertar_ordenado(open_set, vecino)

	push_warning("[Dijkstra] No se encontró camino.")
	return []



func dfs_es_alcanzable(inicio_pos: Vector3, fin_pos: Vector3) -> bool:
	var nodo_inicio: Nodo = mundo_a_grilla(inicio_pos)
	var nodo_fin:    Nodo = mundo_a_grilla(fin_pos)

	if nodo_inicio == null or nodo_fin == null:
		return false

	var pila: Array = []               
	pila.append(nodo_inicio)           

	var visitados: Dictionary = {}
	visitados[nodo_inicio.coordenada] = true

	while pila.size() > 0:

		var actual: Nodo = pila.pop_back()

		if actual.coordenada == nodo_fin.coordenada:
			print("[DFS] ¡Destino alcanzable desde (%d,%d)!" % [
				nodo_inicio.coordenada.x, nodo_inicio.coordenada.y
			])
			return true

		for vecino in obtener_vecinos(actual):
			if not visitados.has(vecino.coordenada):
				visitados[vecino.coordenada] = true
				pila.append(vecino)   

	print("[DFS] Destino NO alcanzable.")
	return false


func dfs_camino(inicio_pos: Vector3, fin_pos: Vector3) -> Array[Vector3]:
	var nodo_inicio: Nodo = mundo_a_grilla(inicio_pos)
	var nodo_fin:    Nodo = mundo_a_grilla(fin_pos)

	if nodo_inicio == null or nodo_fin == null:
		return []

	for nodo in grilla.values():
		nodo.padre = null

	var pila: Array = []
	pila.append(nodo_inicio)

	var visitados: Dictionary = {}
	visitados[nodo_inicio.coordenada] = true

	while pila.size() > 0:
		var actual: Nodo = pila.pop_back()   

		if actual.coordenada == nodo_fin.coordenada:
			return _reconstruir_camino(nodo_fin)

		for vecino in obtener_vecinos(actual):
			if not visitados.has(vecino.coordenada):
				visitados[vecino.coordenada] = true
				vecino.padre = actual          
				pila.append(vecino)            

	return []  







func debug_imprimir_mapa() -> void:
	print("=== MAPA DE GRILLA (%d x %d) ===" % [ancho, alto])
	for fila in range(alto):
		var linea := ""
		for col in range(ancho):
			var nodo: Nodo = grilla.get(Vector2i(col, fila), null)
			if nodo == null:
				linea += "?"
			elif nodo.es_obstaculo:
				linea += "X"
			else:
				linea += "."
		print(linea)
	print("================================")
