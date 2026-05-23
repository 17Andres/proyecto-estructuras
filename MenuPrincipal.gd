extends Control
@export_file("*.tscn") var escena_juego: String = "res://mundo.tscn"
@export_file("*.tscn") var escena_editor: String = "res://editor.tscn"
@onready var btn_jugar: Button = $Panel/VBoxContainer/BtnJugar
@onready var btn_editor: Button = $Panel/VBoxContainer/BtnEditor
@onready var btn_salir: Button = $Panel/VBoxContainer/BtnSalir

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if btn_jugar:
		btn_jugar.pressed.connect(_on_btn_jugar_pressed)
	if btn_editor:
		btn_editor.pressed.connect(_on_btn_editor_pressed)
	if btn_salir:
		btn_salir.pressed.connect(_on_btn_salir_pressed)

func _on_btn_jugar_pressed() -> void:
	print("[MenuPrincipal] Iniciando partida...")
	get_tree().change_scene_to_file(escena_juego)

func _on_btn_editor_pressed() -> void:
	print("[MenuPrincipal] Abriendo editor de niveles...")
	if ResourceLoader.exists(escena_editor):
		get_tree().change_scene_to_file(escena_editor)
	else:
		push_warning("Aún no has creado la escena del editor: " + escena_editor)

func _on_btn_salir_pressed() -> void:
	print("[MenuPrincipal] Saliendo del juego...")
	get_tree().quit()
