class_name InterfazUsuario
extends CanvasLayer

@onready var vida_bar: ProgressBar = $VidaBar

func actualizar_vida(vida_actual: float, vida_max: float) -> void:
	if vida_bar != null:
		vida_bar.max_value = vida_max
		vida_bar.value     = vida_actual

func mostrar_derrota() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	var panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0.7)
	panel.add_theme_stylebox_override("panel", sb)
	add_child(panel)
	
	var label = Label.new()
	label.text = "¡Has perdido!"
	label.set_anchors_preset(Control.PRESET_CENTER)
	label.add_theme_font_size_override("font_size", 64)
	label.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(label)
	label.position.y -= 50
	label.position.x -= label.size.x / 2.0
	
	var btn = Button.new()
	btn.text = "Volver al Menú Principal"
	btn.set_anchors_preset(Control.PRESET_CENTER)
	btn.add_theme_font_size_override("font_size", 24)
	panel.add_child(btn)
	btn.position.y += 50
	btn.position.x -= btn.size.x / 2.0
	
	btn.pressed.connect(_on_btn_volver_pressed)

func _on_btn_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
