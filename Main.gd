
extends Node3D
## Mapa prototipo del ClassicRPG, estilo low-poly.

const GeneradorTerreno := preload("res://scripts/compartido/GeneradorTerreno.gd")

const TAMANO_MUNDO := GeneradorTerreno.TAMANO_MUNDO
const RESOLUCION := GeneradorTerreno.RESOLUCION
const NUM_ARBOLES := GeneradorTerreno.NUM_ARBOLES
const NUM_ROCAS := GeneradorTerreno.NUM_ROCAS

const EscenaJugador := preload("res://Personajes/Jugador.tscn")
const EscenaCamara := preload("res://Camaras/Camara.tscn")
const ScriptMultijugador := preload("res://scripts/cliente/Multijugador.gd")

var ruido: FastNoiseLite
var ruido_detalle: FastNoiseLite
var material_terreno: StandardMaterial3D

var nodo_multijugador: Node
var panel_objetivo: PanelContainer
var etiqueta_objetivo_nombre: Label
var etiqueta_objetivo_info: Label
var barra_vida_objetivo: ProgressBar
var indicador_objetivo_3d: MeshInstance3D
var nodo_objetivo_actual: Node3D = null


func _ready() -> void:
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

	nodo_multijugador = ScriptMultijugador.new()
	add_child(nodo_multijugador)
	nodo_multijugador.iniciar(jugador)
	nodo_multijugador.objetivo_cambiado.connect(_al_cambiar_objetivo)


func _crear_hud() -> void:
	var capa := CanvasLayer.new()
	add_child(capa)

	var etiqueta := Label.new()
	etiqueta.text = "WASD: mover   ·   Espacio: saltar   ·   Shift: correr   ·   Tab: objetivo\nClic derecho + mouse: rotar cámara   ·   Rueda: zoom   ·   Escape: limpiar objetivo"
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

	# Panel de marco de objetivo (Target Frame)
	panel_objetivo = PanelContainer.new()
	panel_objetivo.position = Vector2(24, 80)
	panel_objetivo.custom_minimum_size = Vector2(220, 64)
	panel_objetivo.visible = false

	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.08, 0.09, 0.12, 0.88)
	estilo.border_width_left = 2
	estilo.border_width_top = 2
	estilo.border_width_right = 2
	estilo.border_width_bottom = 2
	estilo.border_color = Color(0.7, 0.6, 0.3, 0.9)
	estilo.corner_radius_top_left = 6
	estilo.corner_radius_top_right = 6
	estilo.corner_radius_bottom_right = 6
	estilo.corner_radius_bottom_left = 6
	estilo.content_margin_left = 10.0
	estilo.content_margin_top = 6.0
	estilo.content_margin_right = 10.0
	estilo.content_margin_bottom = 6.0
	panel_objetivo.add_theme_stylebox_override("panel", estilo)

	var contenedor := VBoxContainer.new()
	contenedor.add_theme_constant_override("separation", 3)
	panel_objetivo.add_child(contenedor)

	etiqueta_objetivo_nombre = Label.new()
	etiqueta_objetivo_nombre.text = "Objetivo"
	etiqueta_objetivo_nombre.add_theme_font_size_override("font_size", 15)
	etiqueta_objetivo_nombre.add_theme_color_override("font_color", Color(1.0, 0.95, 0.8))
	contenedor.add_child(etiqueta_objetivo_nombre)

	barra_vida_objetivo = ProgressBar.new()
	barra_vida_objetivo.custom_minimum_size = Vector2(200, 16)
	barra_vida_objetivo.show_percentage = false
	contenedor.add_child(barra_vida_objetivo)

	etiqueta_objetivo_info = Label.new()
	etiqueta_objetivo_info.text = "Tipo · Estado"
	etiqueta_objetivo_info.add_theme_font_size_override("font_size", 12)
	etiqueta_objetivo_info.add_theme_color_override("font_color", Color(0.75, 0.75, 0.8))
	contenedor.add_child(etiqueta_objetivo_info)

	capa.add_child(panel_objetivo)

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


func _al_cambiar_objetivo(id: int, datos: Dictionary, nodo: Node3D) -> void:
	if id <= 0 or nodo == null or not is_instance_valid(nodo):
		nodo_objetivo_actual = null
		if panel_objetivo != null:
			panel_objetivo.visible = false
		if indicador_objetivo_3d != null:
			indicador_objetivo_3d.visible = false
		return

	nodo_objetivo_actual = nodo
	panel_objetivo.visible = true
	indicador_objetivo_3d.visible = true

	var nombre: String = str(datos.get("name", "Entidad %d" % id))
	if nombre.is_empty():
		nombre = "Entidad %d" % id
	etiqueta_objetivo_nombre.text = nombre

	var hp: int = int(datos.get("hp", 100))
	var hp_max: int = int(datos.get("hp_max", 100))
	barra_vida_objetivo.max_value = hp_max
	barra_vida_objetivo.value = hp

	var tipo: String = str(datos.get("type", "entidad"))
	var estado: String = str(datos.get("estado", "activo"))
	etiqueta_objetivo_info.text = "%s · %s (%d / %d)" % [tipo.capitalize(), estado.capitalize(), hp, hp_max]


func _process(_delta: float) -> void:
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
