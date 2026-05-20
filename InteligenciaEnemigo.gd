
class_name InteligenciaEnemigo
extends CharacterBody3D



@export var grid_manager: GestorCuadricula

@export var jugador: CharacterBody3D

@export var velocidad: float = 4.5

@export var distancia_deteccion: float = 12.0

@export var distancia_ataque: float = 1.5

@export var intervalo_recalculo: float = 0.5

@export_range(0.01, 1.0, 0.01) var velocidad_rotacion: float = 0.15

@export var anim_caminar: String = "Medium Run/mixamo_com"
@export var anim_atacar:  String = "Mutant Punch/mixamo_com"
@export var anim_morir:   String = "Death/mixamo_com"
@export var anim_idle:    String = "T-Pose/mixamo_com"

@export_group("Combate y Vida")
@export var vida_max: float = 100.0
@export var danio_ataque: float = 15.0
@export var intervalo_ataque: float = 2.0



enum Estado { PATRULLANDO, PERSIGUIENDO, ATACANDO, MUERTO }

var estado: Estado = Estado.PATRULLANDO

var _camino: Array = []

var _timer_recalculo: float = 0.0

var _timer_ataque: float = 0.0

var vida_actual: float = 100.0

var _progress_bar: ProgressBar

var _anim: AnimationPlayer = null

var _ultima_anim: String = ""

var _nombre: String = "Enemigo"



func _ready() -> void:
	_nombre = name
	vida_actual = vida_max
	add_to_group("enemigos")
	
	_crear_barra_vida()
	
	_anim = _buscar_animation_player(self)
	if _anim == null:
		push_warning("[InteligenciaEnemigo:%s] No se encontró AnimationPlayer." % _nombre)
	else:
		if _anim.has_animation(anim_idle):
			_anim.get_animation(anim_idle).loop_mode = Animation.LOOP_LINEAR
		if _anim.has_animation(anim_caminar):
			_anim.get_animation(anim_caminar).loop_mode = Animation.LOOP_LINEAR
		if _anim.has_animation(anim_atacar):
			_anim.get_animation(anim_atacar).loop_mode = Animation.LOOP_LINEAR

	_reproducir(anim_idle)


func _physics_process(delta: float) -> void:
	if estado == Estado.MUERTO:
		return

	if jugador == null or grid_manager == null:
		return

	var dist: float = global_position.distance_to(jugador.global_position)

	match estado:
		Estado.PATRULLANDO, Estado.PERSIGUIENDO:
			_logica_persecucion(delta, dist)
		Estado.ATACANDO:
			_logica_ataque(delta, dist)



func _logica_persecucion(delta: float, dist: float) -> void:
	if dist > distancia_deteccion:
		estado = Estado.PATRULLANDO
		_camino.clear()
		velocity = Vector3.ZERO
		move_and_slide()
		_reproducir(anim_idle)
		return

	if dist <= distancia_ataque:
		_camino.clear()
		estado = Estado.ATACANDO
		_reproducir(anim_atacar)
		print("[InteligenciaEnemigo:%s] Atacando al jugador (Dist: %.1fm)" % [_nombre, dist])
		return

	_timer_recalculo -= delta
	if _timer_recalculo <= 0.0:
		_timer_recalculo = intervalo_recalculo
		_recalcular_camino(dist)

	if _camino.is_empty():
		velocity = Vector3.ZERO
		move_and_slide()
		_reproducir(anim_idle)
		return

	_mover_hacia_waypoint(delta)


func _recalcular_camino(dist: float) -> void:
	var nuevo_camino: Array = grid_manager.astar(global_position, jugador.global_position)
	if not nuevo_camino.is_empty():
		_camino = nuevo_camino
		estado = Estado.PERSIGUIENDO
		_reproducir(anim_caminar)
	else:
		_camino.clear()


func _mover_hacia_waypoint(delta: float) -> void:
	var destino: Vector3 = _camino[0]
	var dif: Vector3 = destino - global_position
	dif.y = 0.0
	var dist_wp: float = dif.length()

	if dist_wp < 0.3:
		_camino.pop_front()
		return

	var dir: Vector3 = dif / dist_wp

	if dir.length_squared() > 0.001:
		var target_basis := Basis.looking_at(dir, Vector3.UP)
		var target_y := target_basis.get_euler().y
		rotation.y = lerp_angle(rotation.y, target_y, velocidad_rotacion * delta * 60.0)

	velocity = dir * velocidad
	move_and_slide()



func _logica_ataque(delta: float, dist: float) -> void:
	if dist > distancia_ataque + 0.5:
		estado = Estado.PERSIGUIENDO
		_reproducir(anim_caminar)
		return

	var dir_jugador: Vector3 = (jugador.global_position - global_position)
	dir_jugador.y = 0.0
	if dir_jugador.length_squared() > 0.001:
		var target_basis := Basis.looking_at(dir_jugador.normalized(), Vector3.UP)
		var target_y := target_basis.get_euler().y
		rotation.y = lerp_angle(rotation.y, target_y, 0.2)

	velocity = Vector3.ZERO
	move_and_slide()

	_timer_ataque -= delta
	if _timer_ataque <= 0.0:
		_timer_ataque = intervalo_ataque
		_reproducir(anim_atacar)
		print("[InteligenciaEnemigo:%s] Atacando al jugador!" % _nombre)
		if jugador.has_method("recibir_danio"):
			jugador.recibir_danio(danio_ataque)



func recibir_danio(cantidad: float) -> void:
	if estado == Estado.MUERTO:
		return
	vida_actual -= cantidad
	
	if _progress_bar:
		_progress_bar.value = vida_actual
		
	print("[InteligenciaEnemigo:%s] Recibió daño. Vida: %.1f / %.1f" % [_nombre, vida_actual, vida_max])
	if vida_actual <= 0:
		morir()

func morir() -> void:
	if estado == Estado.MUERTO:
		return
	estado = Estado.MUERTO
	velocity = Vector3.ZERO
	_reproducir(anim_morir)
	print("[InteligenciaEnemigo:%s] Murió." % _nombre)
	if _anim:
		await _anim.animation_finished
	queue_free()



func _buscar_animation_player(nodo: Node) -> AnimationPlayer:
	for hijo in nodo.get_children():
		if hijo is AnimationPlayer:
			return hijo
		var resultado = _buscar_animation_player(hijo)
		if resultado != null:
			return resultado
	return null


func _reproducir(nombre: String) -> void:
	if _anim == null:
		return
	if _ultima_anim == nombre:
		return
	if not _anim.has_animation(nombre):
		return
	_anim.play(nombre, 0.2)
	_ultima_anim = nombre

func _crear_barra_vida() -> void:
	var viewport = SubViewport.new()
	viewport.transparent_bg = true
	viewport.size = Vector2i(150, 20) 
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	
	_progress_bar = ProgressBar.new()
	_progress_bar.set_anchors_preset(Control.PRESET_FULL_RECT)
	_progress_bar.show_percentage = false 
	_progress_bar.max_value = vida_max
	_progress_bar.value = vida_actual
	
	var estilo_fondo = StyleBoxFlat.new()
	estilo_fondo.bg_color = Color(0.1, 0.1, 0.1, 0.7)
	var estilo_relleno = StyleBoxFlat.new()
	estilo_relleno.bg_color = Color(0.8, 0.1, 0.1, 1.0)
	
	_progress_bar.add_theme_stylebox_override("background", estilo_fondo)
	_progress_bar.add_theme_stylebox_override("fill", estilo_relleno)
	
	viewport.add_child(_progress_bar)
	add_child(viewport)
	
	var sprite = Sprite3D.new()
	sprite.texture = viewport.get_texture()
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED 
	sprite.position = Vector3(0, 2.5, 0) 
	add_child(sprite)
