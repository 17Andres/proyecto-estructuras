
class_name MovimientoJugador
extends CharacterBody3D



@export var animation_player: AnimationPlayer

@export var anim_caminar: String = "Walking/mixamo_com"

@export var anim_idle: String = "T-Pose/mixamo_com"

@export var anim_morir: String = "Death/mixamo_com"

@export var anim_atacar: String = "Mutant Punch/mixamo_com"

@export var velocidad_max: float = 6.0

@export_range(0.01, 1.0, 0.01) var aceleracion: float = 0.12

@export_range(0.01, 1.0, 0.01) var desaceleracion: float = 0.18

@export_range(0.01, 1.0, 0.01) var velocidad_rotacion: float = 0.12

@export var blend_animacion: float = 0.2

@export var vida_max: float = 100.0

@export_group("Combate")
@export var danio_ataque: float = 35.0
@export var rango_ataque: float = 2.5
@export var intervalo_ataque: float = 1.0

@export var InterfazUsuario: Node



const ARRIVAL_DIST:    float = 0.2
const VELOCIDAD_MIN:   float = 0.05



enum Estado { IDLE, MOVIENDOSE, FRENANDO, MUERTO, ATACANDO }
var estado: Estado = Estado.IDLE



var camino_actual:     Array    = []
var _vel_actual:       float    = 0.0
var _ultima_anim:      String   = ""
var vida_actual:       float    = 200.0
var _timer_ataque:     float    = 0.0



func _ready() -> void:
	vida_actual = vida_max
	
	if animation_player != null:
		if animation_player.has_animation(anim_caminar):
			animation_player.get_animation(anim_caminar).loop_mode = Animation.LOOP_LINEAR
		if animation_player.has_animation(anim_idle):
			animation_player.get_animation(anim_idle).loop_mode = Animation.LOOP_LINEAR
		if animation_player.has_animation(anim_atacar):
			animation_player.get_animation(anim_atacar).loop_mode = Animation.LOOP_LINEAR

	_transicionar(Estado.IDLE)
	_actualizar_hud()


func _physics_process(delta: float) -> void:
	if estado == Estado.MUERTO:
		return
		
	if _timer_ataque > 0.0:
		_timer_ataque -= delta

	match estado:
		Estado.IDLE:
			velocity = Vector3.ZERO
			move_and_slide()
		Estado.MOVIENDOSE:
			_mover(delta)
		Estado.FRENANDO:
			_frenar(delta)
		Estado.ATACANDO:
			velocity = Vector3.ZERO
			move_and_slide()



func _mover(delta: float) -> void:
	if camino_actual.is_empty():
		_transicionar(Estado.FRENANDO)
		return

	var destino: Vector3 = camino_actual[0]
	var dif: Vector3 = destino - global_position
	dif.y = 0.0
	var dist: float = dif.length()

	if dist <= ARRIVAL_DIST:
		camino_actual.pop_front()
		if camino_actual.is_empty():
			_transicionar(Estado.FRENANDO)
		return

	_vel_actual = lerp(_vel_actual, velocidad_max, aceleracion * delta * 60.0)

	var dir: Vector3 = dif / dist

	if dir.length_squared() > 0.001:
		var target_basis := Basis.looking_at(dir, Vector3.UP)
		var target_y := target_basis.get_euler().y
		rotation.y = lerp_angle(rotation.y, target_y, velocidad_rotacion * delta * 60.0)

	velocity = dir * _vel_actual
	move_and_slide()


func _frenar(delta: float) -> void:
	_vel_actual = lerp(_vel_actual, 0.0, desaceleracion * delta * 60.0)
	velocity    = velocity.normalized() * _vel_actual
	move_and_slide()

	if _vel_actual <= VELOCIDAD_MIN:
		_vel_actual = 0.0
		velocity    = Vector3.ZERO
		move_and_slide()
		_transicionar(Estado.IDLE)



func recibir_danio(cantidad: float) -> void:
	if estado == Estado.MUERTO:
		return
	vida_actual = max(0.0, vida_actual - cantidad)
	_actualizar_hud()
	print("[MovimientoJugador] Vida: %.0f / %.0f" % [vida_actual, vida_max])

	if vida_actual <= 0.0:
		_morir()


func _morir() -> void:
	_transicionar(Estado.MUERTO)
	velocity = Vector3.ZERO
	_reproducir(anim_morir)
	print("[MovimientoJugador] El jugador murió.")


func _actualizar_hud() -> void:
	if InterfazUsuario != null:
		InterfazUsuario.call("actualizar_vida", vida_actual, vida_max)



func set_camino(nuevo_camino: Array) -> void:
	if nuevo_camino.is_empty():
		return
	camino_actual = nuevo_camino
	_transicionar(Estado.MOVIENDOSE)
	print("[MovimientoJugador] Camino nuevo: %d waypoints." % camino_actual.size())


func detener() -> void:
	camino_actual.clear()
	_vel_actual = 0.0
	velocity    = Vector3.ZERO
	move_and_slide()
	_transicionar(Estado.IDLE)

func atacar() -> void:
	if estado == Estado.MUERTO or _timer_ataque > 0.0:
		return
	
	_timer_ataque = intervalo_ataque
	detener() 
	_transicionar(Estado.ATACANDO)
	
	var enemigo_mas_cercano = null
	var dist_minima = rango_ataque + 1.0
	
	var enemigos = get_tree().get_nodes_in_group("enemigos")
	for enemigo in enemigos:
		var dist = global_position.distance_to(enemigo.global_position)
		if dist <= rango_ataque:
			if enemigo.has_method("recibir_danio"):
				enemigo.recibir_danio(danio_ataque)
				if dist < dist_minima:
					dist_minima = dist
					enemigo_mas_cercano = enemigo
					
	if enemigo_mas_cercano != null:
		var dir_enemigo = (enemigo_mas_cercano.global_position - global_position)
		dir_enemigo.y = 0.0
		if dir_enemigo.length_squared() > 0.001:
			var target_basis = Basis.looking_at(dir_enemigo.normalized(), Vector3.UP)
			rotation.y = target_basis.get_euler().y
	
	await get_tree().create_timer(0.5).timeout
	if estado == Estado.ATACANDO:
		_transicionar(Estado.IDLE)



func _transicionar(nuevo: Estado) -> void:
	if estado == nuevo:
		return
	estado = nuevo
	match estado:
		Estado.IDLE:
			_reproducir(anim_idle)
		Estado.MOVIENDOSE:
			_reproducir(anim_caminar)
		Estado.FRENANDO:
			pass   
		Estado.MUERTO:
			pass
		Estado.ATACANDO:
			_reproducir(anim_atacar)


func _reproducir(nombre: String) -> void:
	if animation_player == null:
		return
	if _ultima_anim == nombre:
		return
	if not animation_player.has_animation(nombre):
		push_warning("[MovimientoJugador] Animación no encontrada: '%s'" % nombre)
		return
	animation_player.play(nombre, blend_animacion)
	_ultima_anim = nombre
