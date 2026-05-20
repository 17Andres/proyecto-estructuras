
class_name InterfazUsuario
extends CanvasLayer



@onready var vida_bar: ProgressBar = $VidaBar



func actualizar_vida(vida_actual: float, vida_max: float) -> void:
	if vida_bar == null:
		return
	vida_bar.max_value = vida_max
	vida_bar.value     = vida_actual
