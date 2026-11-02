
extends Node3D
## Mapa prototipo del ClassicRPG, estilo low-poly.

const GeneradorTerreno := preload("res://scripts/compartido/GeneradorTerreno.gd")
const CatalogoObjetos := preload("res://scripts/compartido/CatalogoObjetos.gd")

const TAMANO_MUNDO := GeneradorTerreno.TAMANO_MUNDO
const RESOLUCION := GeneradorTerreno.RESOLUCION
const NUM_ARBOLES := GeneradorTerreno.NUM_ARBOLES
const NUM_ROCAS := GeneradorTerreno.NUM_ROCAS
const PUERTO_LOCAL_INICIAL := 9000
const CANTIDAD_PUERTOS_LOCALES := 100
const META_ULTIMO_PUERTO_LOCAL := "classicrpg_ultimo_puerto_local"

const EscenaJugador := preload("res://Personajes/Jugador.tscn")
const EscenaCamara := preload("res://Camaras/Camara.tscn")
const ScriptMultijugador := preload("res://scripts/cliente/Multijugador.gd")
const ScriptServidorLocal := preload("res://scripts/servidor/Servidor.gd")
const ScriptHUDInicial := preload("res://scripts/cliente/HUDInicial.gd")

var ruido: FastNoiseLite
var ruido_detalle: FastNoiseLite
var material_terreno: StandardMaterial3D

var nodo_multijugador: Node
var panel_objetivo: Control
var etiqueta_objetivo_nombre: Label
var etiqueta_objetivo_info: Label
var barra_vida_objetivo: ProgressBar
var indicador_objetivo_3d: MeshInstance3D
var nodo_objetivo_actual: Node3D = null
var etiqueta_combate: Label
var etiqueta_inventario: Label
var etiqueta_oro: Label
var lista_inventario: ItemList
var panel_inventario: PanelContainer
var boton_descartar_objeto: Button
var boton_comprar_pocion: Button
var dialogo_descartar_objeto: ConfirmationDialog
var id_objeto_seleccionado := ""
var id_objeto_pendiente_descartar := ""
var etiqueta_progresion: Label
var etiqueta_atributos: Label
var boton_mejorar_fuerza: Button
var boton_mejorar_vitalidad: Button
var etiqueta_equipo: Label
var etiqueta_mision: Label
var etiqueta_salud_jugador: Label
var barra_salud_jugador: ProgressBar
var hud_inicial: Node
var tiempo_respawn_ui := 0.0
var tween_combate: Tween
var panel_pausa: Control
var pausa_abierta := false
var direccion_servidor := "ws://127.0.0.1:9000"


func _ready() -> void:
	_iniciar_servidor_local()
	ruido = GeneradorTerreno.crear_ruido_terreno()
	ruido_detalle = GeneradorTerreno.crear_ruido_detalle()

	material_terreno = StandardMaterial3D.new()
	material_terreno.vertex_color_use_as_albedo = true
	material_terreno.roughness = 1.0
	material_terreno.specular_mode = BaseMaterial3D.SPECULAR_DISABLED

	_crear_entorno()
	_crear_luz()
	_crear_terreno()
	_crear_camino()
	_crear_bosque()
	_crear_rocas()
	_crear_jugador()
	_crear_hud()

	print("MAPA: listo, hijos = ", get_child_count())


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_B or event.physical_keycode == KEY_B):
		_alternar_inventario()
		if get_viewport() != null:
			get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_P:
		if pausa_abierta:
			_cerrar_pausa()
		else:
			_abrir_pausa()
		if get_viewport() != null:
			get_viewport().set_input_as_handled()


func _abrir_pausa() -> void:
	if panel_pausa != null:
		return
	pausa_abierta = true
	get_tree().paused = true
	panel_pausa = Control.new()
	panel_pausa.process_mode = Node.PROCESS_MODE_ALWAYS
	panel_pausa.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var fondo := ColorRect.new()
	fondo.color = Color(0.02, 0.03, 0.04, 0.78)
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel_pausa.add_child(fondo)
	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel_pausa.add_child(centro)
	var columna := VBoxContainer.new()
	columna.custom_minimum_size.x = 300.0
	columna.add_theme_constant_override("separation", 14)
	centro.add_child(columna)
	var titulo := Label.new()
	titulo.text = "Partida en pausa"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 28)
	columna.add_child(titulo)
	var reanudar := Button.new()
	reanudar.text = "Reanudar"
	reanudar.pressed.connect(_cerrar_pausa)
	columna.add_child(reanudar)
	var volver := Button.new()
	volver.text = "Guardar y volver al título"
	volver.pressed.connect(_guardar_y_volver_al_titulo)
	columna.add_child(volver)
	add_child(panel_pausa)
	reanudar.grab_focus()


func _cerrar_pausa() -> void:
	if panel_pausa != null:
		panel_pausa.queue_free()
		panel_pausa = null
	pausa_abierta = false
	get_tree().paused = false


func _guardar_y_volver_al_titulo() -> void:
	var servidor_local := get_node_or_null("ServidorLocal")
	if servidor_local != null and servidor_local.has_method("_guardar_partidas_locales"):
		servidor_local.call("_guardar_partidas_locales")
	_cerrar_pausa()
	get_tree().change_scene_to_file("res://MenuInicio.tscn")


func _iniciar_servidor_local() -> void:
	if OS.get_cmdline_user_args().has("--servidor-externo"):
		print("Cliente conectado a servidor externo.")
		return

	var puerto_local := _buscar_puerto_local()
	direccion_servidor = "ws://127.0.0.1:%d" % puerto_local
	var servidor_local: Node = ScriptServidorLocal.new()
	servidor_local.name = "ServidorLocal"
	servidor_local.set("modo_individual", true)
	servidor_local.set("puerto_escucha", puerto_local)
	add_child(servidor_local)
	print("Modo individual: servidor local integrado iniciado en puerto ", puerto_local, ".")


func _buscar_puerto_local() -> int:
	var ultimo_puerto := int(get_tree().root.get_meta(META_ULTIMO_PUERTO_LOCAL, PUERTO_LOCAL_INICIAL - 1))
	for desplazamiento in range(1, CANTIDAD_PUERTOS_LOCALES + 1):
		var puerto := PUERTO_LOCAL_INICIAL + posmod(
			ultimo_puerto - PUERTO_LOCAL_INICIAL + desplazamiento,
			CANTIDAD_PUERTOS_LOCALES
		)
		var prueba := TCPServer.new()
		if prueba.listen(puerto, "*") == OK:
			prueba.stop()
			get_tree().root.set_meta(META_ULTIMO_PUERTO_LOCAL, puerto)
			return puerto
	return PUERTO_LOCAL_INICIAL


func _c(r: float, g: float, b: float) -> Color:
	return Color(r, g, b).srgb_to_linear()


func _crear_entorno() -> void:
	var cielo := Sky.new()
	var mat_cielo := ProceduralSkyMaterial.new()
	mat_cielo.sky_top_color = _c(0.16, 0.36, 0.68)
	mat_cielo.sky_horizon_color = _c(0.74, 0.84, 0.93)
	mat_cielo.ground_bottom_color = _c(0.18, 0.22, 0.18)
	mat_cielo.ground_horizon_color = _c(0.55, 0.63, 0.66)
	cielo.sky_material = mat_cielo

	var ambiente := Environment.new()
	ambiente.background_mode = Environment.BG_SKY
	ambiente.sky = cielo
	ambiente.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	ambiente.ambient_light_energy = 0.45
	ambiente.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	ambiente.tonemap_exposure = 1.0
	ambiente.ssao_enabled = true
	ambiente.ssao_radius = 2.0
	ambiente.ssao_intensity = 2.0
	ambiente.fog_enabled = true
	ambiente.fog_light_color = _c(0.76, 0.82, 0.88)
	ambiente.fog_density = 0.0035
	ambiente.fog_sky_affect = 0.25

	var mundo := WorldEnvironment.new()
	mundo.environment = ambiente
	add_child(mundo)


func _crear_luz() -> void:
	var sol := DirectionalLight3D.new()
	sol.light_color = _c(1.0, 0.94, 0.80)
	sol.light_energy = 1.6
	sol.rotation_degrees = Vector3(-52, -38, 0)
	sol.shadow_enabled = true
	sol.shadow_bias = 0.2
	sol.shadow_normal_bias = 3.0
	sol.shadow_blur = 1.0
	sol.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
	sol.directional_shadow_blend_splits = true
	sol.directional_shadow_max_distance = 120.0
	add_child(sol)


func _crear_jugador() -> void:
	var posicion_aparicion := GeneradorTerreno.posicion_aparicion(0, ruido, ruido_detalle)
	var jugador = EscenaJugador.instantiate()
	jugador.position = posicion_aparicion
	add_child(jugador)

	var camara = EscenaCamara.instantiate()
	camara.position = jugador.position
	add_child(camara)
	camara.objetivo = jugador
	jugador.camara = camara
	camara.nodo_multijugador = nodo_multijugador if nodo_multijugador != null else null

	nodo_multijugador = ScriptMultijugador.new()
	add_child(nodo_multijugador)
	if is_instance_valid(jugador) and is_instance_valid(jugador.camara):
		jugador.camara.nodo_multijugador = nodo_multijugador
	nodo_multijugador.set("direccion_servidor", direccion_servidor)
	nodo_multijugador.iniciar(jugador)
	nodo_multijugador.objetivo_cambiado.connect(_al_cambiar_objetivo)
	nodo_multijugador.resultado_ataque.connect(_al_resultado_ataque)
	nodo_multijugador.inventario_cambiado.connect(_al_cambiar_inventario)
	nodo_multijugador.inventario_rechazado.connect(_al_rechazar_objeto_inventario)
	nodo_multijugador.oro_cambiado.connect(_al_cambiar_oro)
	nodo_multijugador.resultado_compra.connect(_al_resultado_compra)
	nodo_multijugador.resultado_descartar_objeto.connect(_al_resultado_descartar_objeto)
	nodo_multijugador.progresion_cambiada.connect(_al_cambiar_progresion)
	nodo_multijugador.salud_jugador_cambiada.connect(_al_cambiar_salud_jugador)
	nodo_multijugador.mision_cambiada.connect(_al_cambiar_mision)
	nodo_multijugador.resultado_objeto.connect(_al_resultado_objeto)
	nodo_multijugador.equipamiento_cambiado.connect(_al_cambiar_equipamiento)
	nodo_multijugador.resultado_equipamiento.connect(_al_resultado_equipamiento)
	nodo_multijugador.resultado_atributo.connect(_al_resultado_atributo)


func _crear_hud() -> void:
	var capa := CanvasLayer.new()
	add_child(capa)
	hud_inicial = ScriptHUDInicial.new()
	hud_inicial.name = "HUDInicial"
	capa.add_child(hud_inicial)
	panel_objetivo = hud_inicial.get("panel_objetivo") as Control
	etiqueta_objetivo_nombre = hud_inicial.get("etiqueta_objetivo_nombre") as Label
	etiqueta_objetivo_info = hud_inicial.get("etiqueta_objetivo_info") as Label
	barra_vida_objetivo = hud_inicial.get("barra_vida_objetivo") as ProgressBar
	etiqueta_salud_jugador = hud_inicial.get("etiqueta_salud_jugador") as Label
	barra_salud_jugador = hud_inicial.get("barra_salud_jugador") as ProgressBar
	var jugador_hud: Node3D
	var salud_hud: Dictionary = {}
	var progresion_hud: Dictionary = {}
	if nodo_multijugador != null:
		jugador_hud = nodo_multijugador.get("jugador_local") as Node3D
		var salud_actual: Variant = nodo_multijugador.get("salud_local")
		if salud_actual is Dictionary:
			salud_hud = salud_actual.duplicate(true)
		var progresion_actual: Variant = nodo_multijugador.get("progresion")
		if progresion_actual is Dictionary:
			progresion_hud = progresion_actual.duplicate(true)
	hud_inicial.call("configurar_jugador", jugador_hud, salud_hud, progresion_hud)

	var etiqueta := Label.new()
	etiqueta.text = "WASD: mover   ·   Espacio: saltar   ·   Shift: correr   ·   Tab / Clic: objetivo   ·   E: hablar   ·   1: atacar   ·   2: poción   ·   3: golpe pesado (6 s)   ·   Q: equipar   ·   B: inventario   ·   P: pausa\nClic derecho + mouse: rotar cámara   ·   Rueda: zoom   ·   Escape: limpiar objetivo"
	etiqueta.position = Vector2(24, 20)
	etiqueta.add_theme_font_size_override("font_size", 17)
	etiqueta.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
	etiqueta.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	etiqueta.add_theme_constant_override("shadow_offset_x", 2)
	etiqueta.add_theme_constant_override("shadow_offset_y", 2)
	capa.add_child(etiqueta)

	var tween := create_tween()
	tween.tween_interval(9.0)
	tween.tween_property(etiqueta, "modulate:a", 0.0, 2.5)

	etiqueta_combate = Label.new()
	etiqueta_combate.anchor_left = 0.5
	etiqueta_combate.anchor_right = 0.5
	etiqueta_combate.offset_left = -180.0
	etiqueta_combate.offset_right = 180.0
	etiqueta_combate.offset_top = 132.0
	etiqueta_combate.offset_bottom = 164.0
	etiqueta_combate.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta_combate.add_theme_font_size_override("font_size", 14)
	etiqueta_combate.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	etiqueta_combate.add_theme_constant_override("shadow_offset_x", 1)
	etiqueta_combate.add_theme_constant_override("shadow_offset_y", 1)
	etiqueta_combate.text = ""
	capa.add_child(etiqueta_combate)

	_crear_panel_inventario(capa)
	_crear_panel_progresion(capa)
	_crear_panel_mision(capa)
	_crear_panel_equipo(capa)
	if nodo_multijugador != null:
		var salud_actual: Variant = nodo_multijugador.get("salud_local")
		if salud_actual is Dictionary:
			_al_cambiar_salud_jugador(salud_actual)
		var progresion_actual: Variant = nodo_multijugador.get("progresion")
		if progresion_actual is Dictionary:
			_al_cambiar_progresion(progresion_actual)

	# Indicador 3D circular en el suelo
	indicador_objetivo_3d = MeshInstance3D.new()
	var aro := TorusMesh.new()
	aro.inner_radius = 0.7
	aro.outer_radius = 0.85
	aro.rings = 24
	aro.ring_segments = 6
	indicador_objetivo_3d.mesh = aro

	var mat_aro := StandardMaterial3D.new()
	mat_aro.albedo_color = Color(1.0, 0.85, 0.2, 0.9)
	mat_aro.emission_enabled = true
	mat_aro.emission = Color(0.9, 0.75, 0.1, 1.0)
	mat_aro.emission_energy_multiplier = 1.5
	mat_aro.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat_aro.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	indicador_objetivo_3d.material_override = mat_aro
	indicador_objetivo_3d.visible = false
	add_child(indicador_objetivo_3d)
	if nodo_multijugador != null:
		var id_objetivo_inicial := int(nodo_multijugador.get("id_objetivo"))
		if id_objetivo_inicial > 0:
			var datos_entidades: Dictionary = nodo_multijugador.get("datos_entidades")
			var entidades: Dictionary = nodo_multijugador.get("entidades_remotas")
			_al_cambiar_objetivo(id_objetivo_inicial, datos_entidades.get(id_objetivo_inicial, {}), entidades.get(id_objetivo_inicial))


func _crear_panel_inventario(capa: CanvasLayer) -> void:
	panel_inventario = PanelContainer.new()
	var panel := panel_inventario
	panel.visible = false
	panel.anchor_left = 1.0
	panel.anchor_right = 1.0
	panel.offset_left = -284.0
	panel.offset_right = -24.0
	panel.offset_top = 24.0
	panel.offset_bottom = 232.0

	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.08, 0.09, 0.12, 0.88)
	estilo.border_width_left = 2
	estilo.border_width_top = 2
	estilo.border_width_right = 2
	estilo.border_width_bottom = 2
	estilo.border_color = Color(0.55, 0.48, 0.32, 0.9)
	estilo.content_margin_left = 10.0
	estilo.content_margin_top = 8.0
	estilo.content_margin_right = 10.0
	estilo.content_margin_bottom = 8.0
	panel.add_theme_stylebox_override("panel", estilo)

	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 5)
	panel.add_child(columna)

	etiqueta_inventario = Label.new()
	etiqueta_inventario.text = "Inventario (0/%d)" % CatalogoObjetos.CAPACIDAD_RANURAS
	etiqueta_inventario.add_theme_font_size_override("font_size", 14)
	etiqueta_inventario.add_theme_color_override("font_color", Color(0.95, 0.92, 0.82))
	etiqueta_inventario.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columna.add_child(etiqueta_inventario)

	etiqueta_oro = Label.new()
	etiqueta_oro.text = "Oro: 0"
	etiqueta_oro.add_theme_font_size_override("font_size", 13)
	etiqueta_oro.add_theme_color_override("font_color", Color(0.98, 0.78, 0.3))
	columna.add_child(etiqueta_oro)

	lista_inventario = ItemList.new()
	lista_inventario.custom_minimum_size = Vector2(240.0, 112.0)
	lista_inventario.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lista_inventario.select_mode = ItemList.SELECT_SINGLE
	lista_inventario.item_selected.connect(_al_seleccionar_objeto_inventario)
	columna.add_child(lista_inventario)

	boton_descartar_objeto = Button.new()
	boton_descartar_objeto.text = "Descartar 1 seleccionado"
	boton_descartar_objeto.disabled = true
	boton_descartar_objeto.pressed.connect(_descartar_objeto_seleccionado)
	columna.add_child(boton_descartar_objeto)

	boton_comprar_pocion = Button.new()
	var precio_pocion := int(CatalogoObjetos.obtener("pocion_curativa").get("precio_compra", 0))
	boton_comprar_pocion.text = "Comprar poción · %d oro" % precio_pocion
	boton_comprar_pocion.tooltip_text = "Compra junto al Habitante. El servidor comprueba distancia, oro e inventario."
	boton_comprar_pocion.disabled = true
	boton_comprar_pocion.pressed.connect(_comprar_pocion)
	columna.add_child(boton_comprar_pocion)
	capa.add_child(panel)

	dialogo_descartar_objeto = ConfirmationDialog.new()
	dialogo_descartar_objeto.title = "Confirmar descarte"
	dialogo_descartar_objeto.ok_button_text = "Descartar"
	dialogo_descartar_objeto.cancel_button_text = "Cancelar"
	dialogo_descartar_objeto.confirmed.connect(_confirmar_descarte_objeto)
	dialogo_descartar_objeto.canceled.connect(_cancelar_descarte_objeto)
	capa.add_child(dialogo_descartar_objeto)


func _crear_panel_progresion(capa: CanvasLayer) -> void:
	var panel := PanelContainer.new()
	panel.anchor_left = 1.0
	panel.anchor_right = 1.0
	panel.offset_left = -284.0
	panel.offset_right = -24.0
	panel.offset_top = 240.0
	panel.offset_bottom = 364.0

	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.08, 0.09, 0.12, 0.88)
	estilo.border_width_left = 2
	estilo.border_width_top = 2
	estilo.border_width_right = 2
	estilo.border_width_bottom = 2
	estilo.border_color = Color(0.48, 0.58, 0.34, 0.9)
	estilo.content_margin_left = 10.0
	estilo.content_margin_top = 8.0
	estilo.content_margin_right = 10.0
	estilo.content_margin_bottom = 8.0
	panel.add_theme_stylebox_override("panel", estilo)

	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 3)
	panel.add_child(columna)
	etiqueta_progresion = Label.new()
	etiqueta_progresion.text = "Nivel 1 · XP 0 / 100"
	etiqueta_progresion.add_theme_font_size_override("font_size", 14)
	etiqueta_progresion.add_theme_color_override("font_color", Color(0.88, 0.94, 0.78))
	columna.add_child(etiqueta_progresion)
	etiqueta_atributos = Label.new()
	etiqueta_atributos.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	etiqueta_atributos.add_theme_font_size_override("font_size", 11)
	etiqueta_atributos.add_theme_color_override("font_color", Color(0.9, 0.9, 0.82))
	columna.add_child(etiqueta_atributos)
	var fila_botones := HBoxContainer.new()
	fila_botones.add_theme_constant_override("separation", 6)
	columna.add_child(fila_botones)
	boton_mejorar_fuerza = Button.new()
	boton_mejorar_fuerza.text = "+ Fuerza"
	boton_mejorar_fuerza.tooltip_text = "Gasta 1 punto para aumentar el daño cuerpo a cuerpo en 2."
	boton_mejorar_fuerza.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	boton_mejorar_fuerza.pressed.connect(_asignar_fuerza)
	fila_botones.add_child(boton_mejorar_fuerza)
	boton_mejorar_vitalidad = Button.new()
	boton_mejorar_vitalidad.text = "+ Vitalidad"
	boton_mejorar_vitalidad.tooltip_text = "Gasta 1 punto para aumentar la vida máxima y actual en 10."
	boton_mejorar_vitalidad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	boton_mejorar_vitalidad.pressed.connect(_asignar_vitalidad)
	fila_botones.add_child(boton_mejorar_vitalidad)
	capa.add_child(panel)


func _crear_panel_equipo(capa: CanvasLayer) -> void:
	var panel := PanelContainer.new()
	panel.anchor_left = 1.0
	panel.anchor_right = 1.0
	panel.offset_left = -284.0
	panel.offset_right = -24.0
	panel.offset_top = 466.0
	panel.offset_bottom = 522.0

	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.08, 0.09, 0.12, 0.9)
	estilo.border_width_left = 2
	estilo.border_width_top = 2
	estilo.border_width_right = 2
	estilo.border_width_bottom = 2
	estilo.border_color = Color(0.48, 0.53, 0.68, 0.95)
	estilo.content_margin_left = 10.0
	estilo.content_margin_top = 7.0
	estilo.content_margin_right = 10.0
	estilo.content_margin_bottom = 7.0
	panel.add_theme_stylebox_override("panel", estilo)

	etiqueta_equipo = Label.new()
	etiqueta_equipo.text = "Arma: ninguna · Q para equipar"
	etiqueta_equipo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	etiqueta_equipo.add_theme_font_size_override("font_size", 13)
	etiqueta_equipo.add_theme_color_override("font_color", Color(0.82, 0.88, 1.0))
	panel.add_child(etiqueta_equipo)
	capa.add_child(panel)


func _crear_panel_mision(capa: CanvasLayer) -> void:
	var panel := PanelContainer.new()
	panel.anchor_left = 1.0
	panel.anchor_right = 1.0
	panel.offset_left = -284.0
	panel.offset_right = -24.0
	panel.offset_top = 372.0
	panel.offset_bottom = 458.0

	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.08, 0.09, 0.12, 0.9)
	estilo.border_width_left = 2
	estilo.border_width_top = 2
	estilo.border_width_right = 2
	estilo.border_width_bottom = 2
	estilo.border_color = Color(0.62, 0.52, 0.3, 0.95)
	estilo.content_margin_left = 10.0
	estilo.content_margin_top = 8.0
	estilo.content_margin_right = 10.0
	estilo.content_margin_bottom = 8.0
	panel.add_theme_stylebox_override("panel", estilo)

	etiqueta_mision = Label.new()
	etiqueta_mision.text = "Misión disponible\nHabla con el Habitante (Tab + E)."
	etiqueta_mision.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	etiqueta_mision.add_theme_font_size_override("font_size", 14)
	etiqueta_mision.add_theme_color_override("font_color", Color(0.96, 0.91, 0.76))
	panel.add_child(etiqueta_mision)
	capa.add_child(panel)


func _crear_panel_salud(capa: CanvasLayer) -> void:
	var panel := PanelContainer.new()
	panel.anchor_left = 0.0
	panel.anchor_right = 0.0
	panel.anchor_top = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_left = 24.0
	panel.offset_right = 284.0
	panel.offset_top = -94.0
	panel.offset_bottom = -24.0

	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.08, 0.09, 0.12, 0.9)
	estilo.border_width_left = 2
	estilo.border_width_top = 2
	estilo.border_width_right = 2
	estilo.border_width_bottom = 2
	estilo.border_color = Color(0.55, 0.27, 0.24, 0.95)
	estilo.content_margin_left = 10.0
	estilo.content_margin_top = 7.0
	estilo.content_margin_right = 10.0
	estilo.content_margin_bottom = 7.0
	panel.add_theme_stylebox_override("panel", estilo)

	var contenedor := VBoxContainer.new()
	contenedor.add_theme_constant_override("separation", 4)
	panel.add_child(contenedor)

	etiqueta_salud_jugador = Label.new()
	etiqueta_salud_jugador.text = "Vida 100 / 100"
	etiqueta_salud_jugador.add_theme_font_size_override("font_size", 14)
	etiqueta_salud_jugador.add_theme_color_override("font_color", Color(1.0, 0.9, 0.84))
	contenedor.add_child(etiqueta_salud_jugador)

	barra_salud_jugador = ProgressBar.new()
	barra_salud_jugador.custom_minimum_size = Vector2(232.0, 18.0)
	barra_salud_jugador.max_value = 100.0
	barra_salud_jugador.value = 100.0
	barra_salud_jugador.show_percentage = false
	contenedor.add_child(barra_salud_jugador)

	capa.add_child(panel)


func _al_cambiar_progresion(datos: Dictionary) -> void:
	if etiqueta_progresion == null:
		return
	if hud_inicial != null:
		hud_inicial.call("actualizar_nivel", datos)

	var nivel := int(datos.get("level", 1))
	var experiencia := int(datos.get("xp", 0))
	var xp_siguiente := int(datos.get("xp_to_next", 100))
	var puntos := int(datos.get("attribute_points", 0))
	var fuerza := int(datos.get("strength", 0))
	var vitalidad := int(datos.get("vitality", 0))
	etiqueta_progresion.text = "Nivel %d · XP %d / %d · Puntos %d" % [nivel, experiencia, xp_siguiente, puntos]
	if etiqueta_atributos != null:
		etiqueta_atributos.text = "Fuerza %d (+%d daño) · Vitalidad %d (+%d vida)" % [fuerza, fuerza * 2, vitalidad, vitalidad * 10]
	_actualizar_botones_atributo(puntos)


func _actualizar_botones_atributo(puntos: int = -1) -> void:
	if puntos < 0 and nodo_multijugador != null:
		var progresion: Dictionary = nodo_multijugador.get("progresion")
		puntos = int(progresion.get("attribute_points", 0))
	var jugador_controlable := false
	if nodo_multijugador != null:
		var jugador: Node = nodo_multijugador.get("jugador_local")
		jugador_controlable = is_instance_valid(jugador) and bool(jugador.get("controles_habilitados"))
	var deshabilitado := puntos <= 0 or not jugador_controlable
	if boton_mejorar_fuerza != null:
		boton_mejorar_fuerza.disabled = deshabilitado
	if boton_mejorar_vitalidad != null:
		boton_mejorar_vitalidad.disabled = deshabilitado


func _asignar_fuerza() -> void:
	if nodo_multijugador != null:
		nodo_multijugador.asignar_atributo("strength")


func _asignar_vitalidad() -> void:
	if nodo_multijugador != null:
		nodo_multijugador.asignar_atributo("vitality")


func _al_resultado_atributo(datos: Dictionary) -> void:
	if etiqueta_combate == null:
		return
	if is_instance_valid(tween_combate):
		tween_combate.kill()
	var atributo := str(datos.get("attribute", ""))
	var mensaje := "No se pudo asignar el atributo."
	if bool(datos.get("success", false)):
		mensaje = "Fuerza mejorada: +2 daño." if atributo == "strength" else "Vitalidad mejorada: +10 vida máxima y actual."
	else:
		match str(datos.get("reason", "")):
			"no_points":
				mensaje = "No tienes puntos de atributo disponibles."
			"player_dead":
				mensaje = "No puedes mejorar atributos mientras estás derrotado."
			"not_connected":
				mensaje = "Sin conexión con el mundo."
		etiqueta_combate.text = mensaje
		etiqueta_combate.add_theme_color_override("font_color", Color(0.9, 0.45, 0.45))
	if bool(datos.get("success", false)):
		etiqueta_combate.text = mensaje
		etiqueta_combate.add_theme_color_override("font_color", Color(0.86, 0.82, 0.68))
	_actualizar_botones_atributo()
	etiqueta_combate.modulate.a = 1.0
	tween_combate = create_tween()
	tween_combate.tween_interval(2.0)
	tween_combate.tween_property(etiqueta_combate, "modulate:a", 0.0, 0.7)

func _al_cambiar_equipamiento(datos: Dictionary) -> void:
	if etiqueta_equipo == null:
		return
	var id_arma := str(datos.get("arma", ""))
	if id_arma.is_empty():
		etiqueta_equipo.text = "Arma: ninguna · Q para equipar"
	else:
		etiqueta_equipo.text = "Arma: %s" % CatalogoObjetos.nombre(id_arma)


func _al_resultado_equipamiento(datos: Dictionary) -> void:
	if etiqueta_combate == null:
		return
	if is_instance_valid(tween_combate):
		tween_combate.kill()
	var nombre := CatalogoObjetos.nombre(str(datos.get("item_id", "")))
	if bool(datos.get("success", false)):
		etiqueta_combate.text = "%s equipada. Daño aumentado." % nombre
		etiqueta_combate.add_theme_color_override("font_color", Color(0.65, 0.82, 1.0))
	else:
		var mensaje := "No puedes equipar ese objeto."
		match str(datos.get("reason", "")):
			"not_owned":
				mensaje = "No tienes %s." % nombre
			"player_dead":
				mensaje = "No puedes equipar objetos mientras estás derrotado."
			"not_connected":
				mensaje = "Sin conexión con el mundo."
		etiqueta_combate.text = mensaje
		etiqueta_combate.add_theme_color_override("font_color", Color(0.9, 0.45, 0.45))
	etiqueta_combate.modulate.a = 1.0
	tween_combate = create_tween()
	tween_combate.tween_interval(2.0)
	tween_combate.tween_property(etiqueta_combate, "modulate:a", 0.0, 0.7)


func _al_cambiar_mision(datos: Dictionary, mensaje: String) -> void:
	if etiqueta_mision == null:
		return

	var id_mision := str(datos.get("id", "caza_lobos"))
	var estado := str(datos.get("estado", "disponible"))
	if id_mision == "entrega_gelatina_limo":
		var gelatinas := int(datos.get("gelatina", 0))
		var objetivo_gelatinas := int(datos.get("objetivo_gelatina", 3))
		match estado:
			"activa":
				if gelatinas >= objetivo_gelatinas:
					etiqueta_mision.text = "Gelatinas del bosque\nVuelve al Habitante para entregar"
				else:
					etiqueta_mision.text = "Gelatinas del bosque\nReunidas: %d / %d" % [gelatinas, objetivo_gelatinas]
			"completada":
				etiqueta_mision.text = "Gelatinas del bosque\nCompletada · +120 XP"
			_:
				etiqueta_mision.text = "Gelatinas del bosque\nHabla con el Habitante (Tab + E)."
	elif id_mision == "caza_jabalies":
		var jabalies := int(datos.get("jabalies", 0))
		var objetivo_jabalies := int(datos.get("objetivo_jabalies", 3))
		match estado:
			"activa":
				etiqueta_mision.text = "Caza de jabalíes\nDerrotados: %d / %d" % [jabalies, objetivo_jabalies]
			"completada":
				etiqueta_mision.text = "Caza de jabalíes\nCompletada · +60 XP"
			_:
				etiqueta_mision.text = "Caza de jabalíes\nHabla con el Habitante (Tab + E)."
	elif id_mision == "entrega_carne_jabali":
		var carne := int(datos.get("carne", 0))
		var objetivo_carne := int(datos.get("objetivo_carne", 3))
		match estado:
			"activa":
				if carne >= objetivo_carne:
					etiqueta_mision.text = "Provisiones de jabalí\nVuelve al Habitante para entregar"
				else:
					etiqueta_mision.text = "Provisiones de jabalí\nCarne reunida: %d / %d" % [carne, objetivo_carne]
			"completada":
				etiqueta_mision.text = "Provisiones de jabalí\nCompletada · +100 XP"
			_:
				etiqueta_mision.text = "Provisiones de jabalí\nHabla con el Habitante (Tab + E)."
	elif id_mision == "entrega_pieles":
		var pieles := int(datos.get("pieles", 0))
		var objetivo_pieles := int(datos.get("objetivo_pieles", 3))
		match estado:
			"activa":
				if pieles >= objetivo_pieles:
					etiqueta_mision.text = "Entrega de pieles\nVuelve al Habitante para entregar"
				else:
					etiqueta_mision.text = "Entrega de pieles\nReunidas: %d / %d" % [pieles, objetivo_pieles]
			"completada":
				etiqueta_mision.text = "Entrega de pieles\nCompletada · +75 XP"
			_:
				etiqueta_mision.text = "Entrega de pieles\nHabla con el Habitante (Tab + E)."
	else:
		var lobos := int(datos.get("lobos", 0))
		var objetivo := int(datos.get("objetivo_lobos", 3))
		match estado:
			"activa":
				etiqueta_mision.text = "Caza de lobos\nDerrotados: %d / %d" % [lobos, objetivo]
			"completada":
				etiqueta_mision.text = "Caza de lobos\nCompletada · +50 XP"
			_:
				etiqueta_mision.text = "Misión disponible\nHabla con el Habitante (Tab + E)."

	if mensaje.is_empty() or etiqueta_combate == null:
		return
	if is_instance_valid(tween_combate):
		tween_combate.kill()
	etiqueta_combate.text = mensaje
	etiqueta_combate.modulate.a = 1.0
	etiqueta_combate.add_theme_color_override("font_color", Color(0.96, 0.85, 0.45))
	tween_combate = create_tween()
	tween_combate.tween_interval(2.8)
	tween_combate.tween_property(etiqueta_combate, "modulate:a", 0.0, 0.8)


func _al_cambiar_salud_jugador(datos: Dictionary) -> void:
	if etiqueta_salud_jugador == null or barra_salud_jugador == null:
		return
	if hud_inicial != null:
		hud_inicial.call("actualizar_salud", datos)

	var hp_max := maxi(1, int(datos.get("hp_max", 100)))
	var hp := clampi(int(datos.get("hp", hp_max)), 0, hp_max)
	var muerto := bool(datos.get("muerto", false))
	barra_salud_jugador.max_value = hp_max
	barra_salud_jugador.value = hp

	var relleno := StyleBoxFlat.new()
	var proporcion := float(hp) / float(hp_max)
	if proporcion <= 0.25:
		relleno.bg_color = Color(0.78, 0.16, 0.12, 1.0)
	elif proporcion <= 0.55:
		relleno.bg_color = Color(0.88, 0.58, 0.12, 1.0)
	else:
		relleno.bg_color = Color(0.28, 0.68, 0.25, 1.0)
	barra_salud_jugador.add_theme_stylebox_override("fill", relleno)

	if muerto:
		tiempo_respawn_ui = maxf(0.0, float(datos.get("respawn_seconds", 0.0)))
		etiqueta_salud_jugador.text = "Caído · reapareces en %d s" % ceili(tiempo_respawn_ui)
	else:
		tiempo_respawn_ui = 0.0
		etiqueta_salud_jugador.text = "Vida %d / %d" % [hp, hp_max]
	_actualizar_botones_atributo()
	_actualizar_boton_tienda()


func _al_cambiar_inventario(items: Dictionary) -> void:
	if etiqueta_inventario == null or lista_inventario == null:
		return

	etiqueta_inventario.text = "Inventario (%d/%d)" % [items.size(), CatalogoObjetos.CAPACIDAD_RANURAS]
	lista_inventario.clear()
	id_objeto_seleccionado = ""
	if boton_descartar_objeto != null:
		boton_descartar_objeto.disabled = true
	if items.is_empty():
		var indice_vacio := lista_inventario.add_item("Vacío")
		lista_inventario.set_item_disabled(indice_vacio, true)
		return

	var ids: Array = items.keys()
	ids.sort()
	for id_var in ids:
		var id_objeto := str(id_var)
		var indice := lista_inventario.add_item("%s × %d" % [CatalogoObjetos.nombre(id_objeto), int(items[id_var])])
		lista_inventario.set_item_metadata(indice, id_objeto)


func _al_cambiar_oro(cantidad: int) -> void:
	if etiqueta_oro != null:
		etiqueta_oro.text = "Oro: %d" % maxi(0, cantidad)


func _actualizar_boton_tienda() -> void:
	if boton_comprar_pocion == null:
		return
	var jugador_controlable := false
	if nodo_multijugador != null:
		var jugador: Node = nodo_multijugador.get("jugador_local")
		jugador_controlable = is_instance_valid(jugador) and bool(jugador.get("controles_habilitados"))
	boton_comprar_pocion.disabled = not jugador_controlable


func _comprar_pocion() -> void:
	if nodo_multijugador != null:
		nodo_multijugador.comprar_objeto("pocion_curativa")


func _al_seleccionar_objeto_inventario(indice: int) -> void:
	id_objeto_seleccionado = str(lista_inventario.get_item_metadata(indice))
	var jugador_controlable := false
	if nodo_multijugador != null:
		var jugador: Node = nodo_multijugador.get("jugador_local")
		jugador_controlable = is_instance_valid(jugador) and bool(jugador.get("controles_habilitados"))
	if boton_descartar_objeto != null:
		boton_descartar_objeto.disabled = id_objeto_seleccionado.is_empty() or not jugador_controlable


func _descartar_objeto_seleccionado() -> void:
	if id_objeto_seleccionado.is_empty() or nodo_multijugador == null or dialogo_descartar_objeto == null:
		return
	id_objeto_pendiente_descartar = id_objeto_seleccionado
	var cantidad := int(nodo_multijugador.inventario.get(id_objeto_pendiente_descartar, 0))
	var nombre := CatalogoObjetos.nombre(id_objeto_pendiente_descartar)
	dialogo_descartar_objeto.dialog_text = "¿Descartar 1 %s? Te quedarán %d. Esta acción no se puede deshacer." % [nombre, maxi(0, cantidad - 1)]
	dialogo_descartar_objeto.popup_centered()


func _confirmar_descarte_objeto() -> void:
	var id_objeto := id_objeto_pendiente_descartar
	id_objeto_pendiente_descartar = ""
	if id_objeto.is_empty() or nodo_multijugador == null:
		return
	if boton_descartar_objeto != null:
		boton_descartar_objeto.disabled = true
	nodo_multijugador.descartar_objeto(id_objeto)


func _cancelar_descarte_objeto() -> void:
	id_objeto_pendiente_descartar = ""


func _al_resultado_descartar_objeto(datos: Dictionary) -> void:
	if etiqueta_combate == null:
		return
	if is_instance_valid(tween_combate):
		tween_combate.kill()
	var nombre := CatalogoObjetos.nombre(str(datos.get("item_id", "")))
	if bool(datos.get("success", false)):
		etiqueta_combate.text = "Descartaste 1 %s." % nombre
		etiqueta_combate.add_theme_color_override("font_color", Color(0.86, 0.82, 0.68))
	else:
		var mensaje := "No se pudo descartar %s." % nombre
		match str(datos.get("reason", "")):
			"not_owned":
				mensaje = "Ya no tienes %s." % nombre
			"player_dead":
				mensaje = "No puedes descartar objetos mientras estás derrotado."
			"not_connected":
				mensaje = "Sin conexión con el mundo."
		etiqueta_combate.text = mensaje
		etiqueta_combate.add_theme_color_override("font_color", Color(0.9, 0.45, 0.45))
	etiqueta_combate.modulate.a = 1.0
	tween_combate = create_tween()
	tween_combate.tween_interval(2.0)
	tween_combate.tween_property(etiqueta_combate, "modulate:a", 0.0, 0.7)


func _al_resultado_objeto(datos: Dictionary) -> void:
	if etiqueta_combate == null:
		return
	if is_instance_valid(tween_combate):
		tween_combate.kill()

	var id_objeto := str(datos.get("item_id", ""))
	var nombre := CatalogoObjetos.nombre(id_objeto)
	if bool(datos.get("success", false)):
		etiqueta_combate.text = "%s: recuperas %d de vida." % [nombre, int(datos.get("healed", 0))]
		etiqueta_combate.add_theme_color_override("font_color", Color(0.45, 0.95, 0.48))
	else:
		var mensaje := "No puedes usar ese objeto."
		match str(datos.get("reason", "")):
			"health_full":
				mensaje = "Ya tienes la vida completa."
			"not_owned":
				mensaje = "No tienes %s." % nombre
			"player_dead":
				mensaje = "No puedes usar objetos mientras estás derrotado."
			"not_connected":
				mensaje = "Sin conexión con el mundo."
		etiqueta_combate.text = mensaje
		etiqueta_combate.add_theme_color_override("font_color", Color(0.9, 0.45, 0.45))

	etiqueta_combate.modulate.a = 1.0
	tween_combate = create_tween()
	tween_combate.tween_interval(2.0)
	tween_combate.tween_property(etiqueta_combate, "modulate:a", 0.0, 0.7)


func _al_resultado_compra(datos: Dictionary) -> void:
	if etiqueta_combate == null:
		return
	if is_instance_valid(tween_combate):
		tween_combate.kill()
	if bool(datos.get("success", false)):
		etiqueta_combate.text = "Poción comprada por %d de oro." % int(datos.get("price", 0))
		etiqueta_combate.add_theme_color_override("font_color", Color(0.98, 0.78, 0.3))
	else:
		var mensaje := "No se pudo realizar la compra."
		match str(datos.get("reason", "")):
			"shop_out_of_range":
				mensaje = "Acércate al Habitante para comprar."
			"insufficient_gold":
				mensaje = "No tienes suficiente oro."
			"slots_full":
				mensaje = "Inventario lleno. No cabe otra poción."
			"stack_full":
				mensaje = "Ya tienes el máximo de pociones."
			"player_dead":
				mensaje = "No puedes comprar mientras estás derrotado."
			"not_connected":
				mensaje = "Sin conexión con el mundo."
		etiqueta_combate.text = mensaje
		etiqueta_combate.add_theme_color_override("font_color", Color(0.9, 0.45, 0.45))
	etiqueta_combate.modulate.a = 1.0
	tween_combate = create_tween()
	tween_combate.tween_interval(2.0)
	tween_combate.tween_property(etiqueta_combate, "modulate:a", 0.0, 0.7)


func _al_rechazar_objeto_inventario(id_objeto: String, motivo: String) -> void:
	if etiqueta_combate == null:
		return

	if is_instance_valid(tween_combate):
		tween_combate.kill()
	etiqueta_combate.modulate.a = 1.0
	var nombre := CatalogoObjetos.nombre(id_objeto)
	if motivo == "slots_full":
		etiqueta_combate.text = "Inventario lleno. No cabe %s." % nombre
	else:
		etiqueta_combate.text = "La pila de %s está llena." % nombre
	etiqueta_combate.add_theme_color_override("font_color", Color(0.9, 0.45, 0.45))
	tween_combate = create_tween()
	tween_combate.tween_interval(2.0)
	tween_combate.tween_property(etiqueta_combate, "modulate:a", 0.0, 0.7)


func _al_cambiar_objetivo(id: int, datos: Dictionary, nodo: Node3D) -> void:
	if hud_inicial != null:
		hud_inicial.call("actualizar_objetivo", id, datos, nodo)
	if id <= 0 or nodo == null or not is_instance_valid(nodo):
		nodo_objetivo_actual = null
		if panel_objetivo != null:
			panel_objetivo.visible = false
		if indicador_objetivo_3d != null:
			indicador_objetivo_3d.visible = false
		return

	nodo_objetivo_actual = nodo
	indicador_objetivo_3d.visible = true


func _al_resultado_ataque(datos: Dictionary) -> void:
	if etiqueta_combate == null:
		return

	if is_instance_valid(tween_combate):
		tween_combate.kill()

	etiqueta_combate.modulate.a = 1.0

	if bool(datos.get("success", false)):
		var danio := int(datos.get("damage", 0))
		var hp_restante := int(datos.get("target_hp", 0))
		var estado := str(datos.get("target_state", ""))
		var es_golpe_pesado := str(datos.get("skill_id", "normal")) == "golpe_pesado"
		var nombre_ataque := "¡Golpe pesado!" if es_golpe_pesado else "¡Golpe!"
		if estado == "muerto":
			var xp_ganada := int(datos.get("xp_gained", 0))
			if xp_ganada > 0:
				if bool(datos.get("level_up", false)):
					var nivel_nuevo := int(datos.get("new_level", 1))
					etiqueta_combate.text = "¡Objetivo derrotado! +%d XP · ¡Nivel %d!" % [xp_ganada, nivel_nuevo]
				else:
					etiqueta_combate.text = "%s %d de daño. ¡Objetivo derrotado! +%d XP" % [nombre_ataque, danio, xp_ganada]
			else:
				etiqueta_combate.text = "%s %d de daño. ¡Objetivo derrotado!" % [nombre_ataque, danio]
			etiqueta_combate.add_theme_color_override("font_color", Color(1.0, 0.4, 0.3))
		else:
			etiqueta_combate.text = "%s %d de daño (vida restante: %d)" % [nombre_ataque, danio, hp_restante]
			etiqueta_combate.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	else:
		var motivo := str(datos.get("reason", "error"))
		var mensaje_error := "No puedes atacar."
		if motivo == "no_target":
			mensaje_error = "¡No tienes un objetivo seleccionado! (Pulsa Tab para fijar uno)"
		elif motivo == "not_connected":
			mensaje_error = "Sin conexión con el servidor de combate."
		match motivo:
			"out_of_range":
				mensaje_error = "¡Objetivo fuera de alcance!"
			"on_cooldown":
				mensaje_error = "Ataque en tiempo de recarga..."
			"skill_on_cooldown":
				mensaje_error = "Golpe pesado en recarga: %d s." % ceili(float(datos.get("cooldown_restante", 0.0)))
			"invalid_skill":
				mensaje_error = "Habilidad no disponible."
			"target_dead":
				mensaje_error = "El objetivo ya está muerto."
			"player_dead":
				mensaje_error = "No puedes actuar mientras estás derrotado."
			"invalid_target":
				mensaje_error = "Objetivo no válido."
		etiqueta_combate.text = mensaje_error
		etiqueta_combate.add_theme_color_override("font_color", Color(0.9, 0.45, 0.45))

	tween_combate = create_tween()
	tween_combate.tween_interval(1.8)
	tween_combate.tween_property(etiqueta_combate, "modulate:a", 0.0, 0.7)


func _process(delta: float) -> void:
	if tiempo_respawn_ui > 0.0:
		tiempo_respawn_ui = maxf(0.0, tiempo_respawn_ui - delta)
		etiqueta_salud_jugador.text = "Caído · reapareces en %d s" % ceili(tiempo_respawn_ui)

	if is_instance_valid(nodo_objetivo_actual) and indicador_objetivo_3d != null and indicador_objetivo_3d.visible:
		var pos := nodo_objetivo_actual.global_position
		indicador_objetivo_3d.global_position = Vector3(
			pos.x,
			_altura(pos.x, pos.z) + 0.05,
			pos.z
		)
	elif nodo_objetivo_actual != null and not is_instance_valid(nodo_objetivo_actual):
		_al_cambiar_objetivo(0, {}, null)


func _altura(x: float, z: float) -> float:
	return GeneradorTerreno.altura(x, z, ruido, ruido_detalle)


func _color_terreno(altura: float) -> Color:
	if altura < 0.35:
		return _c(0.38, 0.62, 0.22)
	elif altura < 3.0:
		return _c(0.32, 0.55, 0.18)
	elif altura < 7.0:
		return _c(0.42, 0.50, 0.26)
	else:
		return _c(0.52, 0.50, 0.46)


func _triangulo(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	var altura_media := (a.y + b.y + c.y) / 3.0
	var color := _color_terreno(altura_media)
	var variacion := randf_range(-0.05, 0.05)

	color = Color(
		clampf(color.r + variacion, 0.0, 1.0),
		clampf(color.g + variacion, 0.0, 1.0),
		clampf(color.b + variacion, 0.0, 1.0)
	)

	st.set_color(color)
	st.add_vertex(a)
	st.set_color(color)
	st.add_vertex(b)
	st.set_color(color)
	st.add_vertex(c)


func _crear_terreno() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var paso := TAMANO_MUNDO / float(RESOLUCION)
	var mitad := TAMANO_MUNDO * 0.5

	for ix in range(RESOLUCION):
		for iz in range(RESOLUCION):
			var x0 := -mitad + float(ix) * paso
			var z0 := -mitad + float(iz) * paso
			var x1 := x0 + paso
			var z1 := z0 + paso

			var a := Vector3(x0, _altura(x0, z0), z0)
			var b := Vector3(x1, _altura(x1, z0), z0)
			var c := Vector3(x1, _altura(x1, z1), z1)
			var d := Vector3(x0, _altura(x0, z1), z1)

			_triangulo(st, a, b, c)
			_triangulo(st, a, c, d)

	st.generate_normals()
	var malla := st.commit()

	var nodo := MeshInstance3D.new()
	nodo.mesh = malla
	nodo.material_override = material_terreno
	add_child(nodo)

	var cuerpo := StaticBody3D.new()
	var forma := CollisionShape3D.new()
	forma.shape = malla.create_trimesh_shape()
	cuerpo.add_child(forma)
	add_child(cuerpo)


func _crear_camino() -> void:
	var puntos: Array[Vector3] = []
	var z := -TAMANO_MUNDO * 0.5 + 6.0

	while z <= TAMANO_MUNDO * 0.5 - 6.0:
		var x := sin(z * 0.11) * 3.0
		puntos.append(Vector3(x, _altura(x, z) + 0.12, z))
		z += 1.8

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var ancho := 3.0

	for i in range(puntos.size() - 1):
		var p0 := puntos[i]
		var p1 := puntos[i + 1]
		var dir := p1 - p0
		dir.y = 0.0
		dir = dir.normalized()

		var perp := Vector3(dir.z, 0.0, -dir.x) * ancho
		var a := p0 - perp
		var b := p0 + perp
		var c := p1 + perp
		var d := p1 - perp

		var color := _c(0.55, 0.40, 0.24)
		var variacion := randf_range(-0.03, 0.03)

		color = Color(
			clampf(color.r + variacion, 0.0, 1.0),
			clampf(color.g + variacion, 0.0, 1.0),
			clampf(color.b + variacion, 0.0, 1.0)
		)

		st.set_color(color)
		st.add_vertex(a)
		st.set_color(color)
		st.add_vertex(b)
		st.set_color(color)
		st.add_vertex(c)

		st.set_color(color)
		st.add_vertex(a)
		st.set_color(color)
		st.add_vertex(c)
		st.set_color(color)
		st.add_vertex(d)

	st.generate_normals()

	var nodo := MeshInstance3D.new()
	nodo.mesh = st.commit()
	nodo.material_override = material_terreno
	add_child(nodo)


func _material(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 1.0
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	return mat


func _spawn_arbol(pos: Vector3, escala: float, rotacion: float) -> void:
	var arbol := Node3D.new()
	arbol.position = pos
	arbol.scale = Vector3.ONE * escala
	arbol.rotation.y = rotacion
	add_child(arbol)

	var tronco := MeshInstance3D.new()
	var malla_tronco := CylinderMesh.new()
	malla_tronco.top_radius = 0.20
	malla_tronco.bottom_radius = 0.34
	malla_tronco.height = 2.4
	malla_tronco.radial_segments = 6
	malla_tronco.rings = 1
	tronco.mesh = malla_tronco
	tronco.position.y = 1.2
	tronco.material_override = _material(_c(0.28, 0.19, 0.10))
	arbol.add_child(tronco)

	var verde := _c(0.24, 0.62, 0.24)
	var altura := 1.9

	for i in range(3):
		var cono := MeshInstance3D.new()
		var malla_cono := CylinderMesh.new()
		malla_cono.top_radius = 0.0
		malla_cono.bottom_radius = 1.45 - float(i) * 0.32
		malla_cono.height = 1.8
		malla_cono.radial_segments = 7
		malla_cono.rings = 1
		cono.mesh = malla_cono
		cono.position.y = altura + 0.9
		cono.material_override = _material(verde.lightened(float(i) * 0.05))
		arbol.add_child(cono)
		altura += 0.95

	var cuerpo := StaticBody3D.new()
	var forma := CollisionShape3D.new()
	var cilindro := CylinderShape3D.new()
	cilindro.radius = 0.45 * escala
	cilindro.height = 2.4 * escala
	forma.shape = cilindro
	forma.position = pos + Vector3(0.0, 1.2 * escala, 0.0)
	cuerpo.add_child(forma)
	add_child(cuerpo)


func _crear_bosque() -> void:
	var arboles := GeneradorTerreno.generar_arboles()

	for datos in arboles:
		var pos: Vector3 = datos["posicion"]
		pos.y = _altura(pos.x, pos.z)

		_spawn_arbol(
			pos,
			datos["escala"],
			datos["rotacion"]
		)


func _crear_rocas() -> void:
	var rocas := GeneradorTerreno.generar_rocas()

	for datos in rocas:
		var pos: Vector3 = datos["posicion"]
		pos.y = _altura(pos.x, pos.z) + 0.25

		var roca := MeshInstance3D.new()
		var malla := SphereMesh.new()
		malla.radius = 1.0
		malla.height = 2.0
		malla.radial_segments = 5
		malla.rings = 3

		roca.mesh = malla
		roca.position = pos
		roca.scale = datos["escala"]
		roca.rotation = datos["rotacion"]
		roca.material_override = _material(_c(0.52, 0.52, 0.49))
		add_child(roca)

func _alternar_inventario() -> void:
	if panel_inventario != null:
		panel_inventario.visible = not panel_inventario.visible
