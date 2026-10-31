
extends CharacterBody3D
## Caballero low-poly controlable: movimiento, salto, sprint y animacion simple.

const VELOCIDAD := 6.0
const VELOCIDAD_CORRER := 10.0
const ACELERACION := 16.0
const GRAVEDAD := 24.0
const SALTO := 8.0

var camara
var es_local := true
@onready var modelo: Node3D = $Modelo
@onready var pierna_izq: Node3D = $Modelo/PiernaIzq
@onready var pierna_der: Node3D = $Modelo/PiernaDer
@onready var brazo_izq: Node3D = $Modelo/BrazoIzq
@onready var brazo_der: Node3D = $Modelo/BrazoDer
@onready var capa: MeshInstance3D = $Modelo/Capa

var tiempo := 0.0
var tiempo_paso := 0.0
var corriendo := false
var en_el_aire := false
var amplitud_animada := 0.0
var ritmo_animado := 1.0

func _physics_process(delta: float) -> void:
	if not es_local:
		return

	if not is_on_floor():
		velocity.y -= GRAVEDAD * delta
		velocity.y = maxf(velocity.y, -45.0)
	elif velocity.y < 0.0:
		velocity.y = 0.0

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = SALTO

	# Determinar modo activo desde el estado de camara
	# Misma indentaciÃ³n que var entrada
	var camera_mode := "character"
	if camara and camara._orbiting:
		camera_mode = "linked"
	elif camara and camara._freeorbiting:
		camera_mode = "free"

	var entrada := Vector2.ZERO
	if Input.is_action_pressed("move_forward"):
		entrada.y += 1.0
	if Input.is_action_pressed("move_back"):
		entrada.y -= 1.0
	if Input.is_action_pressed("move_left"):
		entrada.x -= 1.0
	if Input.is_action_pressed("move_right"):
		entrada.x += 1.0

	var yaw := 0.0
	if camara:
		yaw = camara.yaw

	var personaje_yaw := modelo.rotation.y
	var effective_yaw := personaje_yaw

	# Elegir yaw efectivo segun modo activo
	if camera_mode == "linked":
		effective_yaw = yaw
	# En modo free o character, el personaje conserva su orientacion
	elif camera_mode == "free":
		effective_yaw = personaje_yaw

	var adelante := Vector3(-sin(effective_yaw), 0.0, -cos(effective_yaw))
	var derecha := Vector3(cos(effective_yaw), 0.0, -sin(effective_yaw))
	var direccion := adelante * entrada.y + derecha * entrada.x
	if direccion.length() > 1.0:
		direccion = direccion.normalized()

	corriendo = Input.is_action_pressed("sprint") and entrada.length_squared() > 0.0
	var rapidez := VELOCIDAD
	if corriendo:
		rapidez = VELOCIDAD_CORRER

	var deseada := direccion * rapidez
	velocity.x = move_toward(velocity.x, deseada.x, ACELERACION * delta)
	velocity.z = move_toward(velocity.z, deseada.z, ACELERACION * delta)

	move_and_slide()
	en_el_aire = not is_on_floor()

	# Modo linked: orientar personaje hacia camara.yaw independientemente del movimiento
	# Modo free/character: NO rotar automaticamente (se conserva orientacion actual)
	if camera_mode == "linked" and camara:
		modelo.rotation.y = lerp_angle(modelo.rotation.y, camara.yaw, 12.0 * delta)


func _process(delta: float) -> void:
	if es_local:
		_animar(delta)

func _animar(delta: float) -> void:
	tiempo += delta
	var rapidez := Vector2(velocity.x, velocity.z).length()
	var amplitud_objetivo := clampf(rapidez / VELOCIDAD, 0.0, 1.6)
	amplitud_animada = lerpf(amplitud_animada, amplitud_objetivo, minf(delta * 8.0, 1.0))
	var amplitud := amplitud_animada
	var factor_ritmo_objetivo := 1.35 if corriendo else 1.0
	ritmo_animado = lerpf(ritmo_animado, factor_ritmo_objetivo, minf(delta * 5.0, 1.0))
	var factor_ritmo := ritmo_animado
	tiempo_paso += delta * (4.0 + rapidez * 1.4) * factor_ritmo
	var balanceo := sin(tiempo_paso) * 0.65 * amplitud
	if amplitud < 0.01:
		balanceo = 0.0

	pierna_izq.rotation.x = balanceo
	pierna_der.rotation.x = -balanceo
	brazo_izq.rotation.x = -balanceo * 0.8
	brazo_der.rotation.x = balanceo * 0.8

	if en_el_aire:
		var factor_postura := minf(delta * 10.0, 1.0)
		var postura_piernas := -0.30 if velocity.y > 0.0 else 0.20
		var postura_brazos := -0.65 if velocity.y > 0.0 else -0.35
		pierna_izq.rotation.x = lerpf(pierna_izq.rotation.x, postura_piernas, factor_postura)
		pierna_der.rotation.x = lerpf(pierna_der.rotation.x, postura_piernas, factor_postura)
		brazo_izq.rotation.x = lerpf(brazo_izq.rotation.x, postura_brazos, factor_postura)
		brazo_der.rotation.x = lerpf(brazo_der.rotation.x, postura_brazos, factor_postura)

	var quieto := 0.0 if en_el_aire else 1.0 - clampf(rapidez / VELOCIDAD, 0.0, 1.0)
	modelo.position.y = sin(tiempo * 2.2) * 0.015 * quieto

	if capa:
		capa.rotation.x = -0.06 + sin(tiempo * 3.0) * 0.03 + clampf(rapidez * 0.02, 0.0, 0.18)

