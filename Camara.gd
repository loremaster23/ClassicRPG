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

func _ready() -> void:
	camara = Camera3D.new()
	camara.fov = 65.0
	camara.near = 0.1
	camara.far = 500.0
	add_child(camara)
	camara.make_current()

func _process(delta: float) -> void:
	if objetivo:
		global_position = objetivo.global_position

	if Input.is_key_pressed(KEY_Q):
		yaw += VELOCIDAD_GIRO * delta
	if Input.is_key_pressed(KEY_E):
		yaw -= VELOCIDAD_GIRO * delta

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
		if evento.button_index == MOUSE_BUTTON_WHEEL_UP:
			distancia_objetivo = maxf(distancia_objetivo - 0.8, DISTANCIA_MIN)
		elif evento.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			distancia_objetivo = minf(distancia_objetivo + 0.8, DISTANCIA_MAX)
	elif evento is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		yaw -= evento.relative.x * SENSIBILIDAD
		pitch = clampf(pitch + evento.relative.y * SENSIBILIDAD, PITCH_MIN, PITCH_MAX)
