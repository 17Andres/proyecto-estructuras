
class_name Nodo
extends RefCounted  



var coordenada: Vector2i = Vector2i.ZERO

var posicion_mundo: Vector3 = Vector3.ZERO



var es_obstaculo: bool = false



var g_cost: float = INF

var h_cost: float = 0.0

var f_cost: float:
	get:
		return g_cost + h_cost

var padre: Nodo = null



func _init(coord: Vector2i, pos: Vector3, obst: bool = false) -> void:
	coordenada    = coord
	posicion_mundo = pos
	es_obstaculo  = obst



func resetear() -> void:
	g_cost = INF
	h_cost = 0.0
	padre  = null


func _to_string() -> String:
	return "Nodo(%d,%d | g=%.1f h=%.1f f=%.1f | obst=%s)" % [
		coordenada.x, coordenada.y,
		g_cost, h_cost, f_cost,
		str(es_obstaculo)
	]
