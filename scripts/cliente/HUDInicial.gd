extends Control
## Presentación compacta del HUD inicial; no procesa controles de juego.

const GeneradorTerreno := preload("res://scripts/compartido/GeneradorTerreno.gd")
const TAMANO_MUNDO: float = GeneradorTerreno.TAMANO_MUNDO

const COLOR_ORO := Color(0.76, 0.59, 0.29, 1.0)
const COLOR_TEXTO := Color(0.94, 0.88, 0.72, 1.0)
const COLOR_TEXTO_SECUNDARIO := Color(0.65, 0.65, 0.62, 1.0)

class MarcoOrnamental extends Panel:
	func _draw() -> void:
		if size.x < 16.0 or size.y < 16.0:
			return
		var remaches := [
			Vector2(8.0, 8.0),
			Vector2(size.x - 8.0, 8.0),
			Vector2(8.0, size.y - 8.0),
			Vector2(size.x - 8.0, size.y - 8.0)
		]
		for punto in remaches:
			draw_circle(punto, 2.2, Color(0.35, 0.24, 0.12, 1.0))
			draw_circle(punto, 1.0, Color(0.88, 0.70, 0.38, 1.0))


class MiniMapaJugador extends Control:
	var jugador: Node3D
	var tamano_mundo := 110.0

	func asignar_jugador(nodo_jugador: Node3D) -> void:
		jugador = nodo_jugador
		queue_redraw()

	func _process(_delta: float) -> void:
		queue_redraw()

	func _draw() -> void:
		var centro := size * 0.5
		var radio := minf(size.x, size.y) * 0.43
		var color_fondo := Color(0.08, 0.12, 0.09, 0.98)
		var color_linea := Color(0.43, 0.48, 0.34, 0.72)
		draw_circle(centro, radio, color_fondo)
		draw_arc(centro, radio, 0.0, TAU, 64, COLOR_ORO, 2.0, true)
		draw_arc(centro, radio * 0.66, 0.0, TAU, 48, color_linea, 1.0, true)
		draw_line(centro + Vector2(-radio * 0.82, 0.0), centro + Vector2(radio * 0.82, 0.0), color_linea, 1.0, true)
		draw_line(centro + Vector2(0.0, -radio * 0.82), centro + Vector2(0.0, radio * 0.82), color_linea, 1.0, true)
		draw_string(
			get_theme_default_font(),
			centro + Vector2(0.0, -radio + 15.0),
			"N",
			HORIZONTAL_ALIGNMENT_CENTER,
			-1,
			10,
			COLOR_ORO
		)

		if not is_instance_valid(jugador):
			return

		var posicion := jugador.global_position
		var marcador := centro + Vector2(posicion.x, -posicion.z) * (radio / (tamano_mundo * 0.5))
		var desplazamiento := marcador - centro
		if desplazamiento.length() > radio - 8.0:
			marcador = centro + desplazamiento.normalized() * (radio - 8.0)

		var nodo_orientacion: Node3D = jugador
		var modelo := jugador.get_node_or_null("Modelo")
		if modelo is Node3D:
			nodo_orientacion = modelo
		var adelante := -nodo_orientacion.global_transform.basis.z
		adelante.y = 0.0
		if adelante.length_squared() < 0.001:
			adelante = Vector3.FORWARD
		adelante = adelante.normalized()
		var direccion := Vector2(adelante.x, -adelante.z).normalized()
		var lateral := Vector2(-direccion.y, direccion.x)
		var flecha := PackedVector2Array([
			marcador + direccion * 8.0,
			marcador - direccion * 6.0 + lateral * 5.0,
			marcador - direccion * 6.0 - lateral * 5.0
		])
		draw_colored_polygon(flecha, Color(0.97, 0.85, 0.49, 1.0))
		draw_circle(marcador, 2.4, Color(0.12, 0.10, 0.06, 1.0))


var jugador: Node3D
var panel_jugador: Panel
var panel_objetivo: Panel
var panel_acciones: Panel
var panel_minimapa: Panel
var etiqueta_personaje: Label
var etiqueta_salud_jugador: Label
var barra_salud_jugador: ProgressBar
var etiqueta_mana: Label
var barra_mana_jugador: ProgressBar
var etiqueta_objetivo_nombre: Label
var etiqueta_objetivo_info: Label
var barra_vida_objetivo: ProgressBar
var barra_acciones: HBoxContainer
var espacios_accion: Array[Panel] = []
var minimapa_jugador: MiniMapaJugador
var retrato_jugador: SubViewportContainer
var modelo_retrato: Node3D

var _textura_cuero: Texture2D


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_textura_cuero = _crear_textura_cuero()
	_crear_marco_jugador()
	_crear_barra_acciones()
	_crear_marco_objetivo()
	_crear_minimapa()


func configurar_jugador(nodo_jugador: Node3D, salud: Dictionary = {}, progresion: Dictionary = {}) -> void:
	jugador = nodo_jugador
	if minimapa_jugador != null:
		minimapa_jugador.tamano_mundo = TAMANO_MUNDO
		minimapa_jugador.asignar_jugador(jugador)
	_actualizar_retrato()
	actualizar_nivel(progresion)
	if not salud.is_empty():
		actualizar_salud(salud)


func actualizar_nivel(datos: Dictionary) -> void:
	if etiqueta_personaje == null:
		return
	var nivel := maxi(1, int(datos.get("level", 1)))
	etiqueta_personaje.text = "Caballero · Nivel %d" % nivel


func actualizar_salud(datos: Dictionary) -> void:
	if etiqueta_salud_jugador == null or barra_salud_jugador == null:
		return
	var hp_max := maxi(1, int(datos.get("hp_max", 100)))
	var hp := clampi(int(datos.get("hp", hp_max)), 0, hp_max)
	barra_salud_jugador.max_value = hp_max
	barra_salud_jugador.value = hp
	etiqueta_salud_jugador.text = "Vida %d / %d" % [hp, hp_max]


func actualizar_objetivo(id: int, datos: Dictionary, nodo_objetivo: Node3D) -> void:
	if panel_objetivo == null:
		return
	if id <= 0 or not is_instance_valid(nodo_objetivo):
		panel_objetivo.visible = false
		return
	var nombre := str(datos.get("name", "Entidad %d" % id))
	var hp_max := maxi(1, int(datos.get("hp_max", 100)))
	var hp := clampi(int(datos.get("hp", hp_max)), 0, hp_max)
	etiqueta_objetivo_nombre.text = nombre if not nombre.is_empty() else "Entidad %d" % id
	etiqueta_objetivo_info.text = "Vida %d / %d" % [hp, hp_max]
	barra_vida_objetivo.max_value = hp_max
	barra_vida_objetivo.value = hp
	panel_objetivo.visible = true


func _crear_marco_jugador() -> void:
	panel_jugador = _crear_marco("MarcoJugador")
	panel_jugador.anchor_left = 0.0
	panel_jugador.anchor_right = 0.0
	panel_jugador.anchor_top = 1.0
	panel_jugador.anchor_bottom = 1.0
	panel_jugador.offset_left = 24.0
	panel_jugador.offset_right = 366.0
	panel_jugador.offset_top = -154.0
	panel_jugador.offset_bottom = -24.0
	add_child(panel_jugador)
	_agregar_textura_cuero(panel_jugador)

	var margen := _crear_margen_contenido(panel_jugador, 10)
	var fila := HBoxContainer.new()
	fila.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fila.add_theme_constant_override("separation", 10)
	margen.add_child(fila)

	retrato_jugador = SubViewportContainer.new()
	retrato_jugador.name = "RetratoCaballero"
	retrato_jugador.custom_minimum_size = Vector2(96.0, 108.0)
	retrato_jugador.stretch = true
	retrato_jugador.mouse_filter = Control.MOUSE_FILTER_IGNORE
	retrato_jugador.tooltip_text = "Retrato del caballero actual"
	fila.add_child(retrato_jugador)
	_crear_escena_retrato()

	var datos := VBoxContainer.new()
	datos.mouse_filter = Control.MOUSE_FILTER_IGNORE
	datos.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	datos.add_theme_constant_override("separation", 3)
	fila.add_child(datos)

	etiqueta_personaje = _crear_etiqueta("Caballero · Nivel 1", 14, COLOR_TEXTO)
	datos.add_child(etiqueta_personaje)
	etiqueta_salud_jugador = _crear_etiqueta("Vida 100 / 100", 12, COLOR_TEXTO)
	datos.add_child(etiqueta_salud_jugador)
	barra_salud_jugador = _crear_barra(Color(0.62, 0.12, 0.12, 1.0), Color(0.16, 0.07, 0.06, 1.0), Vector2(208.0, 18.0))
	barra_salud_jugador.name = "BarraVidaJugador"
	datos.add_child(barra_salud_jugador)
	etiqueta_mana = _crear_etiqueta("Maná · preparado", 11, COLOR_TEXTO_SECUNDARIO)
	datos.add_child(etiqueta_mana)
	barra_mana_jugador = _crear_barra(Color(0.16, 0.42, 0.78, 1.0), Color(0.05, 0.09, 0.17, 1.0), Vector2(208.0, 12.0))
	barra_mana_jugador.name = "BarraManaPreparada"
	barra_mana_jugador.max_value = 100.0
	barra_mana_jugador.value = 0.0
	barra_mana_jugador.tooltip_text = "Espacio visual reservado; el sistema de maná aún no está implementado."
	datos.add_child(barra_mana_jugador)


func _crear_barra_acciones() -> void:
	panel_acciones = _crear_marco("BarraAcciones")
	panel_acciones.anchor_left = 0.5
	panel_acciones.anchor_right = 0.5
	panel_acciones.anchor_top = 1.0
	panel_acciones.anchor_bottom = 1.0
	panel_acciones.offset_left = -170.0
	panel_acciones.offset_right = 170.0
	panel_acciones.offset_top = -88.0
	panel_acciones.offset_bottom = -20.0
	add_child(panel_acciones)
	_agregar_textura_cuero(panel_acciones)

	var margen := _crear_margen_contenido(panel_acciones, 8)
	barra_acciones = HBoxContainer.new()
	barra_acciones.name = "SeisEspaciosDeAccion"
	barra_acciones.mouse_filter = Control.MOUSE_FILTER_IGNORE
	barra_acciones.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	barra_acciones.size_flags_vertical = Control.SIZE_EXPAND_FILL
	barra_acciones.add_theme_constant_override("separation", 6)
	margen.add_child(barra_acciones)

	for indice in range(6):
		var espacio := _crear_marco("EspacioAccion%d" % (indice + 1))
		espacio.custom_minimum_size = Vector2(46.0, 46.0)
		espacio.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		espacio.size_flags_vertical = Control.SIZE_EXPAND_FILL
		barra_acciones.add_child(espacio)
		_agregar_textura_cuero(espacio, 3.0)
		var numero := _crear_etiqueta(str(indice + 1), 9, COLOR_ORO)
		numero.position = Vector2(5.0, 2.0)
		espacio.add_child(numero)
		espacios_accion.append(espacio)


func _crear_marco_objetivo() -> void:
	panel_objetivo = _crear_marco("MarcoObjetivo")
	panel_objetivo.anchor_left = 0.5
	panel_objetivo.anchor_right = 0.5
	panel_objetivo.anchor_top = 0.0
	panel_objetivo.anchor_bottom = 0.0
	panel_objetivo.offset_left = -160.0
	panel_objetivo.offset_right = 160.0
	panel_objetivo.offset_top = 24.0
	panel_objetivo.offset_bottom = 112.0
	panel_objetivo.custom_minimum_size = Vector2(320.0, 88.0)
	panel_objetivo.visible = false
	add_child(panel_objetivo)
	_agregar_textura_cuero(panel_objetivo)

	var margen := _crear_margen_contenido(panel_objetivo, 11)
	var columna := VBoxContainer.new()
	columna.mouse_filter = Control.MOUSE_FILTER_IGNORE
	columna.add_theme_constant_override("separation", 4)
	margen.add_child(columna)
	etiqueta_objetivo_nombre = _crear_etiqueta("Objetivo", 15, COLOR_TEXTO)
	etiqueta_objetivo_nombre.name = "NombreObjetivo"
	columna.add_child(etiqueta_objetivo_nombre)
	barra_vida_objetivo = _crear_barra(Color(0.70, 0.13, 0.12, 1.0), Color(0.16, 0.07, 0.06, 1.0), Vector2(286.0, 18.0))
	barra_vida_objetivo.name = "BarraVidaObjetivo"
	columna.add_child(barra_vida_objetivo)
	etiqueta_objetivo_info = _crear_etiqueta("Vida 100 / 100", 11, COLOR_TEXTO_SECUNDARIO)
	etiqueta_objetivo_info.name = "VidaObjetivo"
	columna.add_child(etiqueta_objetivo_info)


func _crear_minimapa() -> void:
	panel_minimapa = _crear_marco("Minimapa")
	panel_minimapa.anchor_left = 0.0
	panel_minimapa.anchor_right = 0.0
	panel_minimapa.anchor_top = 0.0
	panel_minimapa.anchor_bottom = 0.0
	panel_minimapa.offset_left = 24.0
	panel_minimapa.offset_right = 196.0
	panel_minimapa.offset_top = 78.0
	panel_minimapa.offset_bottom = 250.0
	panel_minimapa.custom_minimum_size = Vector2(172.0, 172.0)
	add_child(panel_minimapa)
	_agregar_textura_cuero(panel_minimapa)

	var margen := _crear_margen_contenido(panel_minimapa, 8)
	var columna := VBoxContainer.new()
	columna.mouse_filter = Control.MOUSE_FILTER_IGNORE
	columna.add_theme_constant_override("separation", 2)
	margen.add_child(columna)
	var titulo := _crear_etiqueta("MAPA", 10, COLOR_ORO)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	columna.add_child(titulo)
	minimapa_jugador = MiniMapaJugador.new()
	minimapa_jugador.name = "PosicionYOrientacionJugador"
	minimapa_jugador.custom_minimum_size = Vector2(140.0, 140.0)
	minimapa_jugador.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	minimapa_jugador.size_flags_vertical = Control.SIZE_EXPAND_FILL
	minimapa_jugador.mouse_filter = Control.MOUSE_FILTER_IGNORE
	columna.add_child(minimapa_jugador)


func _crear_escena_retrato() -> void:
	var vista := SubViewport.new()
	vista.name = "Vista3DDelCaballero"
	vista.size = Vector2i(144, 162)
	vista.own_world_3d = true
	vista.transparent_bg = true
	vista.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	retrato_jugador.add_child(vista)

	var raiz_3d := Node3D.new()
	raiz_3d.name = "EscenaRetrato"
	vista.add_child(raiz_3d)

	var entorno := WorldEnvironment.new()
	var configuracion_entorno := Environment.new()
	configuracion_entorno.background_mode = Environment.BG_COLOR
	configuracion_entorno.background_color = Color(0.035, 0.045, 0.055, 0.0)
	configuracion_entorno.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	configuracion_entorno.ambient_light_color = Color(0.48, 0.52, 0.62, 1.0)
	configuracion_entorno.ambient_light_energy = 0.7
	entorno.environment = configuracion_entorno
	raiz_3d.add_child(entorno)

	var luz := DirectionalLight3D.new()
	luz.rotation_degrees = Vector3(-24.0, -28.0, 0.0)
	luz.light_color = Color(1.0, 0.83, 0.58, 1.0)
	luz.light_energy = 1.15
	raiz_3d.add_child(luz)

	var camara := Camera3D.new()
	camara.name = "CamaraRetrato"
	camara.fov = 36.0
	camara.position = Vector3(0.0, 1.7, 3.15)
	raiz_3d.add_child(camara)
	camara.look_at(Vector3(0.0, 1.65, 0.0), Vector3.UP)
	camara.current = true


func _actualizar_retrato() -> void:
	if not is_instance_valid(jugador) or retrato_jugador == null:
		return
	var modelo := jugador.get_node_or_null("Modelo")
	if not modelo is Node3D:
		return
	var vista := retrato_jugador.get_node_or_null("Vista3DDelCaballero") as SubViewport
	if vista == null:
		return
	var raiz_3d := vista.get_node_or_null("EscenaRetrato") as Node3D
	if raiz_3d == null:
		return
	modelo_retrato = (modelo as Node3D).duplicate() as Node3D
	if modelo_retrato == null:
		return
	modelo_retrato.name = "ModeloRetrato"
	modelo_retrato.position = Vector3.ZERO
	raiz_3d.add_child(modelo_retrato)


func _crear_marco(nombre: String) -> MarcoOrnamental:
	var panel := MarcoOrnamental.new()
	panel.name = nombre
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.075, 0.058, 0.038, 0.97)
	estilo.border_width_left = 3
	estilo.border_width_top = 3
	estilo.border_width_right = 3
	estilo.border_width_bottom = 3
	estilo.border_color = Color(0.49, 0.36, 0.18, 1.0)
	estilo.corner_radius_top_left = 5
	estilo.corner_radius_top_right = 5
	estilo.corner_radius_bottom_right = 5
	estilo.corner_radius_bottom_left = 5
	estilo.shadow_color = Color(0.0, 0.0, 0.0, 0.55)
	estilo.shadow_size = 4
	estilo.shadow_offset = Vector2(1.0, 2.0)
	panel.add_theme_stylebox_override("panel", estilo)
	return panel


func _crear_margen_contenido(panel: Control, margen: int) -> MarginContainer:
	var contenedor := MarginContainer.new()
	contenedor.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	contenedor.add_theme_constant_override("margin_left", margen)
	contenedor.add_theme_constant_override("margin_top", margen)
	contenedor.add_theme_constant_override("margin_right", margen)
	contenedor.add_theme_constant_override("margin_bottom", margen)
	contenedor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(contenedor)
	return contenedor


func _agregar_textura_cuero(panel: Control, inset: float = 4.0) -> void:
	var textura := TextureRect.new()
	textura.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	textura.offset_left = inset
	textura.offset_top = inset
	textura.offset_right = -inset
	textura.offset_bottom = -inset
	textura.texture = _textura_cuero
	textura.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	textura.stretch_mode = TextureRect.STRETCH_TILE
	textura.modulate = Color(0.76, 0.62, 0.38, 0.24)
	textura.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(textura)
	panel.move_child(textura, 0)


func _crear_etiqueta(texto: String, tamano: int, color: Color) -> Label:
	var etiqueta := Label.new()
	etiqueta.text = texto
	etiqueta.add_theme_font_size_override("font_size", tamano)
	etiqueta.add_theme_color_override("font_color", color)
	etiqueta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return etiqueta


func _crear_barra(color_relleno: Color, color_fondo: Color, tamano: Vector2) -> ProgressBar:
	var barra := ProgressBar.new()
	barra.custom_minimum_size = tamano
	barra.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	barra.show_percentage = false
	barra.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fondo := StyleBoxFlat.new()
	fondo.bg_color = color_fondo
	fondo.set_corner_radius_all(3)
	var relleno := StyleBoxFlat.new()
	relleno.bg_color = color_relleno
	relleno.set_corner_radius_all(3)
	barra.add_theme_stylebox_override("background", fondo)
	barra.add_theme_stylebox_override("fill", relleno)
	return barra


func _crear_textura_cuero() -> Texture2D:
	var imagen := Image.create(24, 24, false, Image.FORMAT_RGBA8)
	for y in range(24):
		for x in range(24):
			var ruido := float(((x * 17 + y * 31 + x * y * 7) % 23) - 11)
			var tono := 0.20 + ruido * 0.002
			if y == 0 or x == 0:
				tono *= 0.78
			imagen.set_pixel(x, y, Color(tono, tono * 0.72, tono * 0.45, 1.0))
	return ImageTexture.create_from_image(imagen)
