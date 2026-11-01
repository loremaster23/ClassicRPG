
extends CharacterBody3D
## Caballero low-poly: movimiento y animaciones procedurales estilo WoW Classic.

const VELOCIDAD := 6.0
const VELOCIDAD_CORRER := 10.0
const ACELERACION := 16.0
const GRAVEDAD := 24.0
const SALTO := 8.0

var camara
var es_local := true

@onready var modelo: Node3D = $Modelo
@onready var torso: MeshInstance3D = $Modelo/Torso
@onready var pierna_izq: Node3D = $Modelo/PiernaIzq
@onready var pierna_der: Node3D = $Modelo/PiernaDer
@onready var brazo_izq: Node3D = $Modelo/BrazoIzq
@onready var brazo_der: Node3D = $Modelo/BrazoDer
@onready var capa: MeshInstance3D = $Modelo/Capa
@onready var espada: Node3D = $Modelo/Espada
@onready var hombrera_izq: MeshInstance3D = $Modelo/HombreraIzq
@onready var hombrera_der: MeshInstance3D = $Modelo/HombreraDer

var tiempo := 0.0
var tiempo_paso := 0.0

var corriendo := false
var en_el_aire := false

var amplitud_animada := 0.0
var ritmo_animado := 1.0
var factor_aereo := 0.0

# Transformaciones originales para conservar la escena.
var posicion_modelo_base := Vector3.ZERO
var escala_modelo_base := Vector3.ONE
var posicion_torso_base := Vector3.ZERO

var rotacion_torso_base := Vector3.ZERO
var rotacion_pierna_izq_base := Vector3.ZERO
var rotacion_pierna_der_base := Vector3.ZERO
var rotacion_brazo_izq_base := Vector3.ZERO
var rotacion_brazo_der_base := Vector3.ZERO
var rotacion_capa_base := Vector3.ZERO
var rotacion_espada_base := Vector3.ZERO
var rotacion_hombrera_izq_base := Vector3.ZERO
var rotacion_hombrera_der_base := Vector3.ZERO

# Aterrizaje.
var estaba_en_aire_animacion := false
var tiempo_aterrizaje := 0.0
var fuerza_aterrizaje := 0.0
var velocidad_caida_actual := 0.0


func _ready() -> void:
	posicion_modelo_base = modelo.position
	escala_modelo_base = modelo.scale
	posicion_torso_base = torso.position

	rotacion_torso_base = torso.rotation
	rotacion_pierna_izq_base = pierna_izq.rotation
	rotacion_pierna_der_base = pierna_der.rotation
	rotacion_brazo_izq_base = brazo_izq.rotation
	rotacion_brazo_der_base = brazo_der.rotation
	rotacion_capa_base = capa.rotation
	rotacion_espada_base = espada.rotation
	rotacion_hombrera_izq_base = hombrera_izq.rotation
	rotacion_hombrera_der_base = hombrera_der.rotation


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

	# Determinar el modo activo de la camara.
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

	if camera_mode == "linked":
		effective_yaw = yaw
	elif camera_mode == "free":
		effective_yaw = personaje_yaw

	var adelante := Vector3(
		-sin(effective_yaw),
		0.0,
		-cos(effective_yaw)
	)

	var derecha := Vector3(
		cos(effective_yaw),
		0.0,
		-sin(effective_yaw)
	)

	var direccion := adelante * entrada.y + derecha * entrada.x

	if direccion.length() > 1.0:
		direccion = direccion.normalized()

	corriendo = (
		Input.is_action_pressed("sprint")
		and entrada.length_squared() > 0.0
	)

	var rapidez := VELOCIDAD

	if corriendo:
		rapidez = VELOCIDAD_CORRER

	var deseada := direccion * rapidez

	velocity.x = move_toward(
		velocity.x,
		deseada.x,
		ACELERACION * delta
	)

	velocity.z = move_toward(
		velocity.z,
		deseada.z,
		ACELERACION * delta
	)

	velocidad_caida_actual = maxf(-velocity.y, 0.0)

	move_and_slide()

	en_el_aire = not is_on_floor()

	# Mantener la orientacion vinculada a la camara.
	if camera_mode == "linked" and camara:
		modelo.rotation.y = lerp_angle(
			modelo.rotation.y,
			camara.yaw,
			12.0 * delta
		)


func _process(delta: float) -> void:
	if es_local:
		_animar(delta)


func _animar(delta: float) -> void:
	tiempo += delta

	var rapidez := Vector2(velocity.x, velocity.z).length()
	var velocidad_normalizada := clampf(
		rapidez / VELOCIDAD_CORRER,
		0.0,
		1.0
	)

	var sprint_factor := 1.0 if corriendo else 0.0

	# Detectar el aterrizaje.
	if estaba_en_aire_animacion and not en_el_aire:
		tiempo_aterrizaje = 0.24
		fuerza_aterrizaje = clampf(
			velocidad_caida_actual / SALTO,
			0.25,
			1.0
		)

	estaba_en_aire_animacion = en_el_aire

	if tiempo_aterrizaje > 0.0:
		tiempo_aterrizaje = maxf(
			tiempo_aterrizaje - delta,
			0.0
		)

	var impacto := 0.0

	if tiempo_aterrizaje > 0.0:
		impacto = (
			tiempo_aterrizaje / 0.24
		) * fuerza_aterrizaje

	# Intensidad de locomocion.
	var amplitud_objetivo := clampf(
		rapidez / VELOCIDAD,
		0.0,
		1.6
	)

	amplitud_animada = lerpf(
		amplitud_animada,
		amplitud_objetivo,
		minf(delta * 8.0, 1.0)
	)

	var amplitud := amplitud_animada

	# Ritmo mas rapido durante el sprint.
	var ritmo_objetivo := 1.0 if not corriendo else 1.45

	ritmo_animado = lerpf(
		ritmo_animado,
		ritmo_objetivo,
		minf(delta * 5.0, 1.0)
	)

	tiempo_paso += delta * lerpf(
		5.5,
		10.0,
		sprint_factor
	) * clampf(rapidez / VELOCIDAD, 0.25, 1.6) * ritmo_animado

	# Ciclo de piernas exagerado.
	var ciclo := sin(tiempo_paso)
	var ciclo_secundario := sin(tiempo_paso * 2.0)

	var amplitud_piernas := lerpf(
		0.85,
		1.25,
		sprint_factor
	)

	var balanceo_piernas := (
		ciclo * amplitud_piernas * amplitud
	)

	var pierna_izq_objetivo := (
		rotacion_pierna_izq_base.x + balanceo_piernas
	)

	var pierna_der_objetivo := (
		rotacion_pierna_der_base.x - balanceo_piernas
	)

	# Brazos contrarios a las piernas.
	var brazo_izq_objetivo := (
		rotacion_brazo_izq_base.x
		- balanceo_piernas * 0.55
	)

	var brazo_der_objetivo := (
		rotacion_brazo_der_base.x
		+ balanceo_piernas * 0.45
	)

	# La espada tiene algo mas de peso y movimiento.
	var espada_balanceo := (
		sin(tiempo_paso + 0.5) * 0.12 * amplitud
	)

	# Postura aerea.
	var objetivo_aereo := 1.0 if en_el_aire else 0.0

	factor_aereo = move_toward(
		factor_aereo,
		objetivo_aereo,
		delta * 8.0
	)

	var postura_piernas := -0.45 if velocity.y > 0.0 else 0.25
	var postura_brazos := -0.75 if velocity.y > 0.0 else -0.40

	pierna_izq.rotation.x = lerpf(
		pierna_izq_objetivo,
		rotacion_pierna_izq_base.x + postura_piernas,
		factor_aereo
	)

	pierna_der.rotation.x = lerpf(
		pierna_der_objetivo,
		rotacion_pierna_der_base.x + postura_piernas,
		factor_aereo
	)

	brazo_izq.rotation.x = lerpf(
		brazo_izq_objetivo,
		rotacion_brazo_izq_base.x + postura_brazos,
		factor_aereo
	)

	brazo_der.rotation.x = lerpf(
		brazo_der_objetivo,
		rotacion_brazo_der_base.x + postura_brazos,
		factor_aereo
	)

	# Movimiento lateral de brazos.
	brazo_izq.rotation.z = lerpf(
		brazo_izq.rotation.z,
		rotacion_brazo_izq_base.z + ciclo_secundario * 0.07 * amplitud,
		minf(delta * 9.0, 1.0)
	)

	brazo_der.rotation.z = lerpf(
		brazo_der.rotation.z,
		rotacion_brazo_der_base.z - ciclo_secundario * 0.05 * amplitud,
		minf(delta * 9.0, 1.0)
	)

	# Respiracion y postura de reposo.
	var quieto := (
		1.0 - clampf(rapidez / VELOCIDAD, 0.0, 1.0)
	) * (1.0 - factor_aereo)

	var respiracion := sin(tiempo * 2.2)
	var respiracion_lenta := sin(tiempo * 1.1)

	modelo.position.y = (
		posicion_modelo_base.y
		+ respiracion * 0.025 * quieto
		- impacto * 0.055
	)

	# Compresion del cuerpo al aterrizar.
	var escala_impacto := impacto * 0.045

	modelo.scale = Vector3(
		escala_modelo_base.x * (1.0 + escala_impacto),
		escala_modelo_base.y * (1.0 - escala_impacto),
		escala_modelo_base.z * (1.0 + escala_impacto)
	)

	# Torso: inclinacion al correr y recuperacion al aterrizar.
	var inclinacion := lerpf(
		-0.07,
		-0.17,
		sprint_factor
	) * amplitud * (1.0 - factor_aereo)

	torso.rotation.x = lerpf(
		torso.rotation.x,
		rotacion_torso_base.x + inclinacion + impacto * 0.12,
		minf(delta * 7.0, 1.0)
	)

	torso.rotation.z = lerpf(
		torso.rotation.z,
		rotacion_torso_base.z
		+ sin(tiempo_paso) * 0.035 * amplitud,
		minf(delta * 7.0, 1.0)
	)

	torso.position.y = (
		posicion_torso_base.y
		+ respiracion * 0.018 * quieto
	)

	# Espada: oscilacion de reposo y locomocion.
	espada.rotation = rotacion_espada_base + Vector3(
		espada_balanceo * (1.0 - factor_aereo),
		sin(tiempo * 1.5) * 0.025 * quieto,
		0.0
	)

	# Hombreras con movimiento sutil.
	hombrera_izq.rotation.x = (
		rotacion_hombrera_izq_base.x
		+ sin(tiempo_paso) * 0.045 * amplitud
	)

	hombrera_der.rotation.x = (
		rotacion_hombrera_der_base.x
		- sin(tiempo_paso) * 0.045 * amplitud
	)

	# Capa: mas desplazamiento al correr.
	var movimiento_capa := (
		-0.07
		- velocidad_normalizada * 0.16
		+ sin(tiempo * 3.0) * 0.045
		+ sin(tiempo_paso) * 0.025 * amplitud
	)

	movimiento_capa = lerpf(
		movimiento_capa,
		0.12,
		factor_aereo * 0.5
	)

	capa.rotation.x = lerpf(
		capa.rotation.x,
		rotacion_capa_base.x + movimiento_capa,
		minf(delta * 5.0, 1.0)
	)

	capa.rotation.z = lerpf(
		capa.rotation.z,
		rotacion_capa_base.z
		+ sin(tiempo * 2.0) * 0.035 * quieto,
		minf(delta * 4.0, 1.0)
	)
