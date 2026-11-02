extends Node3D
## Camara orbital en tercera persona con colision contra el terreno.

const DISTANCIA_MIN := 4.0
const DISTANCIA_MAX := 22.0
const SENSIBILIDAD := 0.0045
const UMBRAL_ARRASTRE_IZQUIERDO := 4.0
const PITCH_MIN := -0.10
const PITCH_MAX := 1.15
const ALTURA_FOCO := 1.55
const VELOCIDAD_GIRO := 1.8

var objetivo: Node3D
var camara: Camera3D
var nodo_multijugador: Node
var _pos_clic_izquierdo := Vector2.ZERO
var _posicion_raton_retorno := Vector2.ZERO
var _raton_capturado_por_camara := false
var _clic_izquierdo_pulsado := false
var _distancia_arrastre_izquierdo := 0.0

var yaw := 0.0
var pitch := 0.38
var distancia := 8.0
var distancia_objetivo := 8.0

# Estados independientes para cada boton
var _orbiting := false
var _freeorbiting := false

func _ready() -> void:
	camara = $Camera3D
	camara.make_current()

func _process(delta: float) -> void:
	if objetivo:
		global_position = objetivo.global_position

	distancia = lerpf(distancia, distancia_objetivo, clampf(10.0 * delta, 0.0, 1.0))
	_colocar_camara()

func _colocar_camara() -> void:
	var offset := Vector3(0.0, sin(pitch), cos(pitch)) * distancia
	offset = offset.rotated(Vector3.UP, yaw)
	var foco := global_position + Vector3(0.0, ALTURA_FOCO, 0.0)
	var deseada := global_position + offset

	if objetivo:
		var cuerpo := objetivo as CollisionObject3D
		if cuerpo:
			var espacio := get_world_3d().direct_space_state
			var consulta := PhysicsRayQueryParameters3D.create(foco, deseada)
			consulta.exclude = [cuerpo.get_rid()]
			var resultado := espacio.intersect_ray(consulta)
			if resultado:
				deseada = resultado.position + (foco - deseada).normalized() * 0.35

	camara.global_position = deseada
	camara.look_at(foco, Vector3.UP)

func _unhandled_input(evento: InputEvent) -> void:
	if evento is InputEventMouseButton:
		if evento.button_index == MOUSE_BUTTON_RIGHT:
			if evento.pressed:
				_orbiting = true
				_actualizar_modo_raton(evento.position)
			else:
				_orbiting = false
				_actualizar_modo_raton()

		if evento.button_index == MOUSE_BUTTON_LEFT:
			if evento.pressed:
				_pos_clic_izquierdo = evento.position
				_clic_izquierdo_pulsado = true
				_distancia_arrastre_izquierdo = 0.0
				_seleccionar_objetivo_con_cursor(_pos_clic_izquierdo)
			else:
				_clic_izquierdo_pulsado = false
				_distancia_arrastre_izquierdo = 0.0
				_freeorbiting = false
				_actualizar_modo_raton()
	if evento is InputEventMouseButton:
		if Input.is_action_pressed("camera_zoom_in"):
			distancia_objetivo = maxf(distancia_objetivo - 0.8, DISTANCIA_MIN)
		elif Input.is_action_pressed("camera_zoom_out"):
			distancia_objetivo = minf(distancia_objetivo + 0.8, DISTANCIA_MAX)

	if evento is InputEventMouseMotion:
		if _clic_izquierdo_pulsado and not _freeorbiting:
			_distancia_arrastre_izquierdo += evento.relative.length()
			if _distancia_arrastre_izquierdo >= UMBRAL_ARRASTRE_IZQUIERDO:
				_freeorbiting = true
				_actualizar_modo_raton(_pos_clic_izquierdo)
		if _orbiting or _freeorbiting:
			yaw -= evento.relative.x * SENSIBILIDAD
			pitch = clampf(pitch + evento.relative.y * SENSIBILIDAD, PITCH_MIN, PITCH_MAX)

func _actualizar_modo_raton(posicion_cursor_al_capturar: Vector2 = Vector2.ZERO) -> void:
	if _orbiting or _freeorbiting:
		if not _raton_capturado_por_camara:
			_posicion_raton_retorno = get_viewport().get_final_transform() * posicion_cursor_al_capturar
			_raton_capturado_por_camara = true
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if _raton_capturado_por_camara:
			Input.warp_mouse(_posicion_raton_retorno)
			_raton_capturado_por_camara = false

func _seleccionar_objetivo_con_cursor(pos_pantalla: Vector2) -> void:
	if camara == null or nodo_multijugador == null:
		return
	if not nodo_multijugador.has_method("seleccionar_objetivo_por_rayo"):
		return
	var origen := camara.project_ray_origin(pos_pantalla)
	var direccion := camara.project_ray_normal(pos_pantalla)
	nodo_multijugador.call("seleccionar_objetivo_por_rayo", origen, direccion, 75.0)
