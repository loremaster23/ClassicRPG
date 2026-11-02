extends Control

const ESCENA_JUEGO := "res://Mapa1/Escena1.tscn"
const GUARDADO_LOCAL := "user://classicrpg_partida.json"
var ruta_guardado_local := GUARDADO_LOCAL

var boton_jugar: Button
var boton_continuar: Button
var boton_borrar: Button
var dialogo_borrar: ConfirmationDialog


func _ready() -> void:
	_construir_menu()
	_actualizar_opciones()


func _construir_menu() -> void:
	var fondo := ColorRect.new()
	fondo.color = Color(0.035, 0.055, 0.07, 1.0)
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fondo)

	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(centro)

	var columna := VBoxContainer.new()
	columna.custom_minimum_size = Vector2(380.0, 0.0)
	columna.add_theme_constant_override("separation", 18)
	centro.add_child(columna)

	var titulo := Label.new()
	titulo.text = "CLASSIC RPG"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 38)
	titulo.add_theme_color_override("font_color", Color(0.91, 0.79, 0.51))
	columna.add_child(titulo)

	var subtitulo := Label.new()
	subtitulo.text = "Una aventura en el bosque"
	subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitulo.add_theme_font_size_override("font_size", 16)
	subtitulo.add_theme_color_override("font_color", Color(0.78, 0.83, 0.82))
	columna.add_child(subtitulo)

	boton_jugar = Button.new()
	boton_jugar.custom_minimum_size.y = 48.0
	boton_jugar.pressed.connect(_iniciar_partida)
	columna.add_child(boton_jugar)

	boton_continuar = Button.new()
	boton_continuar.text = "Continuar partida"
	boton_continuar.custom_minimum_size.y = 48.0
	boton_continuar.pressed.connect(_continuar_partida)
	columna.add_child(boton_continuar)

	boton_borrar = Button.new()
	boton_borrar.text = "Borrar guardado y empezar de nuevo"
	boton_borrar.pressed.connect(func() -> void: dialogo_borrar.popup_centered())
	columna.add_child(boton_borrar)

	dialogo_borrar = ConfirmationDialog.new()
	dialogo_borrar.title = "Borrar partida guardada"
	dialogo_borrar.dialog_text = "Esta acción eliminará permanentemente el progreso local. ¿Quieres continuar?"
	dialogo_borrar.confirmed.connect(_borrar_guardado_confirmado)
	add_child(dialogo_borrar)

	var salir := Button.new()
	salir.text = "Salir"
	salir.custom_minimum_size.y = 42.0
	salir.pressed.connect(get_tree().quit)
	columna.add_child(salir)

	var ayuda := Label.new()
	ayuda.text = "WASD mover · Tab / Clic objetivo · E hablar · 1 atacar · 2 poción · 3 golpe pesado · B inventario · Q equipo"
	ayuda.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ayuda.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ayuda.add_theme_color_override("font_color", Color(0.70, 0.75, 0.74))
	columna.add_child(ayuda)


func _actualizar_opciones() -> void:
	var hay_guardado := FileAccess.file_exists(ruta_guardado_local)
	boton_jugar.text = "Nueva partida" if not hay_guardado else "Partida guardada encontrada"
	boton_jugar.disabled = hay_guardado
	boton_continuar.disabled = not hay_guardado
	boton_borrar.disabled = not hay_guardado


func _iniciar_partida() -> void:
	if not FileAccess.file_exists(ruta_guardado_local):
		get_tree().change_scene_to_file(ESCENA_JUEGO)


func _continuar_partida() -> void:
	if FileAccess.file_exists(ruta_guardado_local):
		get_tree().change_scene_to_file(ESCENA_JUEGO)


func _borrar_guardado_confirmado() -> void:
	if not FileAccess.file_exists(ruta_guardado_local):
		_actualizar_opciones()
		return
	var ruta_absoluta := ruta_guardado_local if ruta_guardado_local.is_absolute_path() else ProjectSettings.globalize_path(ruta_guardado_local)
	var error := DirAccess.remove_absolute(ruta_absoluta)
	if error != OK:
		push_error("No se pudo borrar el guardado local: %s" % error)
		return
	_actualizar_opciones()
