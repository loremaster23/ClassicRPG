extends Node3D
## Camara orbital en tercera persona con colision contra el terreno.

const DISTANCIA_MIN := 4.0
const DISTANCIA_MAX := 22.0
const SENSIBILIDAD := 0.0045
const PITCH_MIN := -0.10
const PITCH_MAX := 1.15
const ALTURA_FOCO := 1.55
const VELOCIDAD_GIRO := 1.8

var objetivo: Node3D
var camara: Camera3D

var yaw := 0.0
var pitch := 0.38
var distancia := 8.0
var distancia_objetivo := 8.0

# Estados independientes para cada boton
var _orbiting := false   # boton derecho (camera_orbit_character) - activa modo linked
var _freeorbiting := false # boton izquierdo (camera_orbit_free) - activa modo free

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
	# Detectar pulsaciones y liberaciones usando eventos de ratón y actions InputMap
	if evento is InputEventMouseButton:
		# Boton derecho: camera_orbit_character
		if evento.button_index == MOUSE_BUTTON_RIGHT:
			if evento.pressed:
				_orbiting = true
			else:
				# Siempre establece _orbiting = false al liberar
				# No desactives _freeorbiting. Así, si el izquierdo continúa pulsado, el modo libre seguirá activo.
				_orbiting = false

		# Boton izquierdo: camera_orbit_free
		if evento.button_index == MOUSE_BUTTON_LEFT:
			if evento.pressed:
				_freeorbiting = true
			else:
				_freeorbiting = false

	# Zoom mediante acciones del InputMap
	if evento is InputEventMouseButton:
		if Input.is_action_pressed("camera_zoom_in"):
			distancia_objetivo = maxf(distancia_objetivo - 0.8, DISTANCIA_MIN)
		elif Input.is_action_pressed("camera_zoom_out"):
			distancia_objetivo = minf(distancia_objetivo + 0.8, DISTANCIA_MAX)

	# Rotar la cámara - procesar motion despues de los events
	if evento is InputEventMouseMotion and (_orbiting or _freeorbiting):
		# Rotar tanto si esta en modo linked como en modo free
		yaw -= evento.relative.x * SENSIBILIDAD
		pitch = clampf(pitch + evento.relative.y * SENSIBILIDAD, PITCH_MIN, PITCH_MAX)
