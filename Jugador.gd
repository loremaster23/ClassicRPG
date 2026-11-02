
extends CharacterBody3D
## Caballero low-poly: movimiento y animaciones procedurales estilo WoW Classic.

const VELOCIDAD := 6.0
const VELOCIDAD_CORRER := 10.0
const ACELERACION := 16.0
const GRAVEDAD := 24.0
const SALTO := 8.0
const ANGULO_BRAZO_BASE_QUATERNIUS := 1.15
const UMBRAL_CORRER_ANIMACION := VELOCIDAD * 0.85
const UMBRAL_SPRINT_ANIMACION := VELOCIDAD_CORRER * 0.85
const TIEMPO_INICIO_SALTO_ANIMACION := 0.24

var camara
var es_local := true
var controles_habilitados := true

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
@onready var visual_quaternius: Node3D = $Modelo/VisualQuaternius
@onready var rig_animaciones_quaternius: Node3D = $Modelo/VisualQuaternius/RigAnimacionesQuaternius

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

# Combate procedural.
var tiempo_ataque := 0.0
var potencia_animacion_ataque := 1.0
var duracion_animacion_ataque := 0.35
const DURACION_ATAQUE := 0.35
const DURACION_GOLPE_PESADO := 0.55

# Los dos modelos Quaternius comparten el rig humanoide de 65 huesos.
# Se guardan sus poses de reposo para aplicar las mismas curvas del caballero.
var esqueletos_quaternius: Array[Dictionary] = []
var esqueleto_animaciones_quaternius: Skeleton3D
var animation_tree_quaternius: AnimationTree
var playback_animacion_quaternius: AnimationNodeStateMachinePlayback
var animacion_quaternius_activa := false
var salto_animacion_pendiente := false
var tiempo_aire_animacion := 0.0


func animar_ataque(skill_id: String = "normal") -> void:
	potencia_animacion_ataque = 1.6 if skill_id == "golpe_pesado" else 1.0
	duracion_animacion_ataque = DURACION_GOLPE_PESADO if skill_id == "golpe_pesado" else DURACION_ATAQUE
	tiempo_ataque = duracion_animacion_ataque


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
	animacion_quaternius_activa = _configurar_animaciones_quaternius()
	_preparar_esqueletos_quaternius()
	if not animacion_quaternius_activa:
		push_warning("No se pudo preparar la Universal Animation Library; se conserva la animacion de respaldo.")


func _physics_process(delta: float) -> void:
	if not es_local:
		return

	if not is_on_floor():
		velocity.y -= GRAVEDAD * delta
		velocity.y = maxf(velocity.y, -45.0)
	elif velocity.y < 0.0:
		velocity.y = 0.0

	if not controles_habilitados:
		velocity.x = move_toward(velocity.x, 0.0, ACELERACION * delta)
		velocity.z = move_toward(velocity.z, 0.0, ACELERACION * delta)
		corriendo = false
		move_and_slide()
		en_el_aire = not is_on_floor()
		return
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = SALTO
		salto_animacion_pendiente = true

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
	if en_el_aire:
		tiempo_aire_animacion += delta
	else:
		tiempo_aire_animacion = 0.0

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

	# Animacion de ataque (balanceo de espada).
	var arco_corte := 0.0
	if tiempo_ataque > 0.0:
		tiempo_ataque = maxf(0.0, tiempo_ataque - delta)
		var progreso_ataque := 1.0 - (tiempo_ataque / duracion_animacion_ataque)
		arco_corte = sin(progreso_ataque * PI) * potencia_animacion_ataque

	brazo_izq.rotation.x = lerpf(
		brazo_izq_objetivo,
		rotacion_brazo_izq_base.x + postura_brazos,
		factor_aereo
	)

	brazo_der.rotation.x = lerpf(
		brazo_der_objetivo,
		rotacion_brazo_der_base.x + postura_brazos,
		factor_aereo
	) - arco_corte * 1.3

	# Movimiento lateral de brazos.
	brazo_izq.rotation.z = lerpf(
		brazo_izq.rotation.z,
		rotacion_brazo_izq_base.z + ciclo_secundario * 0.07 * amplitud,
		minf(delta * 9.0, 1.0)
	)

	brazo_der.rotation.z = lerpf(
		brazo_der.rotation.z,
		rotacion_brazo_der_base.z - ciclo_secundario * 0.05 * amplitud + arco_corte * 0.35,
		minf(delta * 9.0, 1.0)
	)

	# Respiracion y postura de reposo.
	var quieto := (
		1.0 - clampf(rapidez / VELOCIDAD, 0.0, 1.0)
	) * (1.0 - factor_aereo)

	var respiracion := sin(tiempo * 2.2)
	var respiracion_lenta := sin(tiempo * 1.1)

	if not animacion_quaternius_activa:
		modelo.position.y = (
			posicion_modelo_base.y
			+ respiracion * 0.025 * quieto
			- impacto * 0.055
		)

	# Compresion del cuerpo al aterrizar.
	var escala_impacto := impacto * 0.045

	if not animacion_quaternius_activa:
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

	torso.rotation.y = rotacion_torso_base.y + arco_corte * 0.22

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

	# Espada: oscilacion de reposo, locomocion y arco de ataque.
	espada.rotation = rotacion_espada_base + Vector3(
		espada_balanceo * (1.0 - factor_aereo) + arco_corte * 1.6,
		sin(tiempo * 1.5) * 0.025 * quieto - arco_corte * 0.45,
		-arco_corte * 0.35
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

	if animacion_quaternius_activa:
		_actualizar_arbol_animacion_quaternius(rapidez)
		_orientar_visual_quaternius(delta)
	else:
		_animar_esqueletos_quaternius(
			balanceo_piernas,
			amplitud,
			ciclo,
			ciclo_secundario,
			factor_aereo,
			postura_piernas,
			postura_brazos,
			arco_corte,
			inclinacion,
			impacto,
			quieto,
			respiracion
		)


func _preparar_esqueletos_quaternius() -> void:
	esqueletos_quaternius.clear()
	for nodo in modelo.find_children("*", "Skeleton3D", true, false):
		var esqueleto := nodo as Skeleton3D
		if esqueleto == null or esqueleto.get_bone_count() < 60:
			continue
		if esqueleto == esqueleto_animaciones_quaternius:
			continue

		var huesos: Dictionary = {}
		for nombre in [
			&"pelvis", &"spine_01", &"spine_02", &"spine_03",
			&"neck_01", &"Head", &"upperarm_l", &"upperarm_r",
			&"lowerarm_l", &"lowerarm_r", &"thigh_l", &"thigh_r",
			&"calf_l", &"calf_r", &"foot_l", &"foot_r"
		]:
			var indice := esqueleto.find_bone(nombre)
			if indice < 0:
				continue
			var resto_local := esqueleto.get_bone_rest(indice).basis.orthonormalized()
			var resto_global := esqueleto.get_bone_global_rest(indice).basis.orthonormalized()
			huesos[nombre] = {
				"indice": indice,
				"resto_local": resto_local.get_rotation_quaternion(),
				"resto_global": resto_global.get_rotation_quaternion()
			}

		if not huesos.has(&"upperarm_l") or not huesos.has(&"thigh_l"):
			continue

		var transform_esqueleto_en_modelo := esqueleto.transform
		var antecesor := esqueleto.get_parent()
		while antecesor != null and antecesor != modelo:
			transform_esqueleto_en_modelo = antecesor.transform * transform_esqueleto_en_modelo
			antecesor = antecesor.get_parent()
		var base_esqueleto_en_modelo := transform_esqueleto_en_modelo.basis.orthonormalized()
		esqueletos_quaternius.append({
			"esqueleto": esqueleto,
			"huesos": huesos,
			"base_esqueleto_en_modelo": base_esqueleto_en_modelo
		})


func _animar_esqueletos_quaternius(
	balanceo_piernas: float,
	amplitud: float,
	ciclo: float,
	ciclo_secundario: float,
	factor_aereo_actual: float,
	postura_piernas: float,
	postura_brazos: float,
	arco_corte: float,
	inclinacion: float,
	impacto: float,
	quieto: float,
	respiracion: float
) -> void:
	if esqueletos_quaternius.is_empty():
		return

	var balanceo_torso := sin(tiempo_paso) * 0.035 * amplitud
	var giro_torso := arco_corte * 0.22
	var respiracion_pecho := respiracion * 0.018 * quieto

	var pierna_izq := lerpf(balanceo_piernas, postura_piernas, factor_aereo_actual)
	var pierna_der := lerpf(-balanceo_piernas, postura_piernas, factor_aereo_actual)
	pierna_izq += impacto * 0.12
	pierna_der += impacto * 0.12

	var brazo_izq := lerpf(
		-balanceo_piernas * 0.55 + ciclo_secundario * 0.07 * amplitud,
		postura_brazos,
		factor_aereo_actual
	)
	var brazo_der := lerpf(
		balanceo_piernas * 0.45 - ciclo_secundario * 0.05 * amplitud - arco_corte * 1.3,
		postura_brazos,
		factor_aereo_actual
	)

	var flexion_rodilla_izq := maxf(0.0, sin(ciclo + 0.35)) * 0.24 * amplitud
	var flexion_rodilla_der := maxf(0.0, sin(ciclo + PI + 0.35)) * 0.24 * amplitud
	if factor_aereo_actual > 0.0:
		var flexion_aerea := 0.3 if velocity.y > 0.0 else 0.48
		flexion_rodilla_izq = lerpf(flexion_rodilla_izq, flexion_aerea, factor_aereo_actual)
		flexion_rodilla_der = lerpf(flexion_rodilla_der, flexion_aerea, factor_aereo_actual)
	flexion_rodilla_izq += impacto * 0.38
	flexion_rodilla_der += impacto * 0.38

	for datos_esqueleto in esqueletos_quaternius:
		var esqueleto := datos_esqueleto["esqueleto"] as Skeleton3D
		var huesos: Dictionary = datos_esqueleto["huesos"]
		var base_esqueleto_en_modelo: Basis = datos_esqueleto["base_esqueleto_en_modelo"]

		_aplicar_rotacion_hueso_modelo(
			esqueleto, huesos, base_esqueleto_en_modelo, &"thigh_l",
			Quaternion(Vector3.RIGHT, pierna_izq)
		)
		_aplicar_rotacion_hueso_modelo(
			esqueleto, huesos, base_esqueleto_en_modelo, &"thigh_r",
			Quaternion(Vector3.RIGHT, pierna_der)
		)
		_aplicar_rotacion_hueso_modelo(
			esqueleto, huesos, base_esqueleto_en_modelo, &"calf_l",
			Quaternion(Vector3.RIGHT, flexion_rodilla_izq)
		)
		_aplicar_rotacion_hueso_modelo(
			esqueleto, huesos, base_esqueleto_en_modelo, &"calf_r",
			Quaternion(Vector3.RIGHT, flexion_rodilla_der)
		)
		_aplicar_rotacion_hueso_modelo(
			esqueleto, huesos, base_esqueleto_en_modelo, &"foot_l",
			Quaternion(Vector3.RIGHT, -pierna_izq * 0.2 - flexion_rodilla_izq * 0.25)
		)
		_aplicar_rotacion_hueso_modelo(
			esqueleto, huesos, base_esqueleto_en_modelo, &"foot_r",
			Quaternion(Vector3.RIGHT, -pierna_der * 0.2 - flexion_rodilla_der * 0.25)
		)

		var bajar_brazo_izq := Quaternion(
			Vector3.BACK,
			-ANGULO_BRAZO_BASE_QUATERNIUS
		)
		var bajar_brazo_der := Quaternion(
			Vector3.BACK,
			ANGULO_BRAZO_BASE_QUATERNIUS
		)
		_aplicar_rotacion_hueso_modelo(
			esqueleto, huesos, base_esqueleto_en_modelo, &"upperarm_l",
			Quaternion(Vector3.RIGHT, brazo_izq) * bajar_brazo_izq
		)
		_aplicar_rotacion_hueso_modelo(
			esqueleto, huesos, base_esqueleto_en_modelo, &"upperarm_r",
			Quaternion(Vector3.RIGHT, brazo_der) * bajar_brazo_der
		)

		var giro_columna := _cuaternion_animacion(
			inclinacion * 0.34 + impacto * 0.04 + respiracion_pecho * 0.2,
			0.0,
			balanceo_torso * 0.25
		)
		_aplicar_rotacion_hueso_modelo(
			esqueleto, huesos, base_esqueleto_en_modelo, &"spine_01", giro_columna
		)
		giro_columna = _cuaternion_animacion(
			inclinacion * 0.33 + impacto * 0.04 + respiracion_pecho * 0.4,
			0.0,
			balanceo_torso * 0.35
		)
		_aplicar_rotacion_hueso_modelo(
			esqueleto, huesos, base_esqueleto_en_modelo, &"spine_02", giro_columna
		)
		giro_columna = _cuaternion_animacion(
			inclinacion * 0.33 + impacto * 0.04 + respiracion_pecho * 0.4,
			giro_torso,
			balanceo_torso * 0.4
		)
		_aplicar_rotacion_hueso_modelo(
			esqueleto, huesos, base_esqueleto_en_modelo, &"spine_03", giro_columna
		)
		_aplicar_rotacion_hueso_modelo(
			esqueleto, huesos, base_esqueleto_en_modelo, &"neck_01",
			_cuaternion_animacion(-inclinacion * 0.08, -giro_torso * 0.2, -balanceo_torso * 0.2)
		)
		_aplicar_rotacion_hueso_modelo(
			esqueleto, huesos, base_esqueleto_en_modelo, &"Head",
			_cuaternion_animacion(-inclinacion * 0.08, -giro_torso * 0.2, -balanceo_torso * 0.2)
		)


func _cuaternion_animacion(x: float, y: float, z: float) -> Quaternion:
	return (
		Quaternion(Vector3.RIGHT, x)
		* Quaternion(Vector3.UP, y)
		* Quaternion(Vector3.BACK, z)
	).normalized()


func _aplicar_rotacion_hueso_modelo(
	esqueleto: Skeleton3D,
	huesos: Dictionary,
	base_esqueleto_en_modelo: Basis,
	nombre: StringName,
	delta_modelo: Quaternion
) -> void:
	if not huesos.has(nombre):
		return

	var datos: Dictionary = huesos[nombre]
	var indice: int = int(datos["indice"])
	var rotacion_resto_local: Quaternion = datos["resto_local"]
	var rotacion_resto_global: Quaternion = datos["resto_global"]
	var rotacion_modelo_a_esqueleto := base_esqueleto_en_modelo.get_rotation_quaternion()
	var delta_esqueleto := (
		rotacion_modelo_a_esqueleto.inverse()
		* delta_modelo
		* rotacion_modelo_a_esqueleto
	)
	var delta_local := (
		rotacion_resto_global.inverse()
		* delta_esqueleto
		* rotacion_resto_global
	)
	esqueleto.set_bone_pose_rotation(
		indice,
		(rotacion_resto_local * delta_local).normalized()
	)


func _configurar_animaciones_quaternius() -> bool:
	var esqueleto_ranger := $Modelo/VisualQuaternius/AparienciaQuaternius.find_child(
		"Skeleton3D", true, false
	) as Skeleton3D
	var nodo_cabeza := $Modelo/VisualQuaternius/CabezaBaseQuaternius
	var esqueleto_cabeza := nodo_cabeza.find_child("Skeleton3D", true, false) as Skeleton3D
	esqueleto_animaciones_quaternius = rig_animaciones_quaternius.find_child(
		"Skeleton3D", true, false
	) as Skeleton3D
	var animation_player := rig_animaciones_quaternius.find_child(
		"AnimationPlayer", true, false
	) as AnimationPlayer
	if (
		esqueleto_ranger == null
		or esqueleto_cabeza == null
		or esqueleto_animaciones_quaternius == null
		or animation_player == null
	):
		return false

	for nombre_animacion in ["Idle", "Walk", "Jog_Fwd", "Sprint", "Jump_Start", "Jump", "Jump_Land"]:
		if not animation_player.has_animation(nombre_animacion):
			push_warning("Falta el clip UAL requerido: %s" % nombre_animacion)
			return false

	for esqueleto_objetivo in [esqueleto_ranger, esqueleto_cabeza]:
		if esqueleto_objetivo.get_bone_count() < 60:
			return false
		for indice in range(esqueleto_animaciones_quaternius.get_bone_count()):
			if esqueleto_objetivo.find_bone(
				esqueleto_animaciones_quaternius.get_bone_name(indice)
			) < 0:
				push_warning("El rig de destino no contiene el hueso UAL: %s" % esqueleto_animaciones_quaternius.get_bone_name(indice))
				return false

	# El paquete de animacion trae un maniqui guia; se oculta y se conserva su esqueleto fuente.
	for nodo in rig_animaciones_quaternius.find_children("*", "MeshInstance3D", true, false):
		(nodo as MeshInstance3D).visible = false

	var perfil := SkeletonProfile.new()
	perfil.bone_size = esqueleto_animaciones_quaternius.get_bone_count()
	perfil.root_bone = &"root"
	perfil.scale_base_bone = &"pelvis"
	for indice in range(esqueleto_animaciones_quaternius.get_bone_count()):
		var nombre_hueso := esqueleto_animaciones_quaternius.get_bone_name(indice)
		perfil.set_bone_name(indice, nombre_hueso)
		var padre := esqueleto_animaciones_quaternius.get_bone_parent(indice)
		perfil.set_bone_parent(
			indice,
			esqueleto_animaciones_quaternius.get_bone_name(padre) if padre >= 0 else &""
		)

	# Guardar transformaciones en el espacio local de VisualQuaternius. Esto conserva
	# el ensamblado original sin depender de global_transform durante _ready.
	var transform_fuente_visual := _transform_local_hasta_ancestro(
		esqueleto_animaciones_quaternius,
		visual_quaternius
	)
	var transform_ranger_visual := _transform_local_hasta_ancestro(esqueleto_ranger, visual_quaternius)
	var transform_cabeza_visual := _transform_local_hasta_ancestro(esqueleto_cabeza, visual_quaternius)

	# Godot retargetea a partir del esqueleto fuente hacia los esqueletos hijos del modificador.
	var retarget := RetargetModifier3D.new()
	retarget.name = "RetargetMaleRanger"
	esqueleto_animaciones_quaternius.add_child(retarget)
	retarget.profile = perfil
	esqueleto_ranger.owner = null
	esqueleto_ranger.reparent(retarget, false)
	esqueleto_ranger.transform = transform_fuente_visual.affine_inverse() * transform_ranger_visual
	esqueleto_ranger.name = "SkeletonMaleRanger"
	esqueleto_cabeza.owner = null
	esqueleto_cabeza.reparent(retarget, false)
	esqueleto_cabeza.transform = transform_fuente_visual.affine_inverse() * transform_cabeza_visual
	esqueleto_cabeza.name = "SkeletonCabezaRanger"

	var locomocion := AnimationNodeBlendSpace2D.new()
	locomocion.min_space = Vector2(-1.0, -1.0)
	locomocion.max_space = Vector2(1.0, 1.0)
	locomocion.x_label = "direccion lateral"
	locomocion.y_label = "avance/retroceso"
	locomocion.add_blend_point(_nodo_animacion_ual(&"Idle"), Vector2.ZERO, -1, &"Reposo")
	var puntos_caminar := [
		Vector2(0.0, 1.0), Vector2(0.707, 0.707), Vector2(1.0, 0.0),
		Vector2(0.707, -0.707), Vector2(0.0, -1.0), Vector2(-0.707, -0.707),
		Vector2(-1.0, 0.0), Vector2(-0.707, 0.707)
	]
	var nombres_direccion := [
		"Adelante", "AdelanteDerecha", "Derecha", "AtrasDerecha",
		"Atras", "AtrasIzquierda", "Izquierda", "AdelanteIzquierda"
	]
	for indice in range(puntos_caminar.size()):
		locomocion.add_blend_point(
			_nodo_animacion_ual(&"Walk"),
			puntos_caminar[indice],
			-1,
			StringName("Caminar" + nombres_direccion[indice])
		)

	var estados := AnimationNodeStateMachine.new()
	estados.add_node("Locomocion", locomocion, Vector2(0, 120))
	estados.add_node("Correr", _nodo_animacion_ual(&"Jog_Fwd"), Vector2(260, 120))
	estados.add_node("Sprint", _nodo_animacion_ual(&"Sprint"), Vector2(500, 120))
	estados.add_node("SaltoInicio", _nodo_animacion_ual(&"Jump_Start"), Vector2(0, -120))
	estados.add_node("Aire", _nodo_animacion_ual(&"Jump"), Vector2(250, -120))
	estados.add_node("Caida", _nodo_animacion_ual(&"Jump"), Vector2(500, -120))
	estados.add_node("Aterrizaje", _nodo_animacion_ual(&"Jump_Land"), Vector2(750, -120))
	_agregar_transicion_ual(estados, "Locomocion", "Correr", "quiere_correr", 0.2)
	_agregar_transicion_ual(estados, "Locomocion", "Sprint", "quiere_sprint", 0.2)
	_agregar_transicion_ual(estados, "Correr", "Locomocion", "no_corre", 0.2)
	_agregar_transicion_ual(estados, "Correr", "Sprint", "quiere_sprint", 0.2)
	_agregar_transicion_ual(estados, "Sprint", "Locomocion", "no_corre", 0.2)
	_agregar_transicion_ual(estados, "Sprint", "Correr", "quiere_correr", 0.2)
	_agregar_transicion_ual(estados, "Locomocion", "SaltoInicio", "salto_iniciado", 0.12)
	_agregar_transicion_ual(estados, "Correr", "SaltoInicio", "salto_iniciado", 0.12)
	_agregar_transicion_ual(estados, "Sprint", "SaltoInicio", "salto_iniciado", 0.12)
	_agregar_transicion_ual(estados, "Locomocion", "Caida", "descendiendo", 0.16)
	_agregar_transicion_ual(estados, "Correr", "Caida", "descendiendo", 0.16)
	_agregar_transicion_ual(estados, "Sprint", "Caida", "descendiendo", 0.16)
	_agregar_transicion_ual(estados, "SaltoInicio", "Aire", "inicio_aereo", 0.12)
	_agregar_transicion_ual(estados, "SaltoInicio", "Caida", "descendiendo", 0.12)
	_agregar_transicion_ual(estados, "Aire", "Caida", "descendiendo", 0.12)
	_agregar_transicion_ual(estados, "SaltoInicio", "Aterrizaje", "aterrizado", 0.12)
	_agregar_transicion_ual(estados, "Aire", "Aterrizaje", "aterrizado", 0.12)
	_agregar_transicion_ual(estados, "Caida", "Aterrizaje", "aterrizado", 0.12)
	_agregar_transicion_ual(
		estados,
		"Aterrizaje",
		"Locomocion",
		"",
		0.18,
		AnimationNodeStateMachineTransition.SWITCH_MODE_AT_END
	)

	animation_tree_quaternius = AnimationTree.new()
	animation_tree_quaternius.name = "AnimationTree"
	rig_animaciones_quaternius.add_child(animation_tree_quaternius)
	animation_tree_quaternius.anim_player = animation_tree_quaternius.get_path_to(animation_player)
	animation_tree_quaternius.root_node = NodePath("..")
	animation_tree_quaternius.tree_root = estados
	animation_tree_quaternius.active = true
	playback_animacion_quaternius = animation_tree_quaternius.get(
		"parameters/playback"
	) as AnimationNodeStateMachinePlayback
	if playback_animacion_quaternius == null:
		return false
	playback_animacion_quaternius.start("Locomocion")
	return true


func _nodo_animacion_ual(nombre: StringName) -> AnimationNodeAnimation:
	var nodo := AnimationNodeAnimation.new()
	nodo.animation = nombre
	return nodo


func _transform_local_hasta_ancestro(nodo: Node3D, ancestro: Node3D) -> Transform3D:
	var transformacion := Transform3D.IDENTITY
	var actual: Node3D = nodo
	while actual != null and actual != ancestro:
		transformacion = actual.transform * transformacion
		actual = actual.get_parent() as Node3D
	return transformacion


func _agregar_transicion_ual(
	estados: AnimationNodeStateMachine,
	origen: StringName,
	destino: StringName,
	condicion: StringName,
	tiempo_cruce: float,
	modo_cambio: AnimationNodeStateMachineTransition.SwitchMode = AnimationNodeStateMachineTransition.SWITCH_MODE_IMMEDIATE
) -> void:
	var transicion := AnimationNodeStateMachineTransition.new()
	transicion.advance_mode = AnimationNodeStateMachineTransition.ADVANCE_MODE_AUTO
	transicion.advance_condition = condicion
	transicion.xfade_time = tiempo_cruce
	transicion.switch_mode = modo_cambio
	estados.add_transition(origen, destino, transicion)


func _actualizar_arbol_animacion_quaternius(rapidez: float) -> void:
	if animation_tree_quaternius == null or not animation_tree_quaternius.active:
		return

	var base_modelo := modelo.global_basis if modelo.is_inside_tree() else modelo.basis
	var direccion_local := base_modelo.orthonormalized().inverse() * Vector3(
		velocity.x,
		0.0,
		velocity.z
	)
	var posicion_blend := Vector2(direccion_local.x, -direccion_local.z)
	if posicion_blend.length() > 0.001:
		posicion_blend = posicion_blend.normalized() * clampf(rapidez / VELOCIDAD, 0.0, 1.0)
	animation_tree_quaternius.set("parameters/Locomocion/blend_position", posicion_blend)

	var quiere_sprint := corriendo and rapidez >= UMBRAL_SPRINT_ANIMACION
	var quiere_correr := (
		corriendo
		and rapidez >= UMBRAL_CORRER_ANIMACION
		and not quiere_sprint
	)
	animation_tree_quaternius.set("parameters/conditions/quiere_correr", quiere_correr)
	animation_tree_quaternius.set("parameters/conditions/quiere_sprint", quiere_sprint)
	animation_tree_quaternius.set(
		"parameters/conditions/no_corre",
		not quiere_correr and not quiere_sprint and not salto_animacion_pendiente and not en_el_aire
	)
	animation_tree_quaternius.set("parameters/conditions/salto_iniciado", salto_animacion_pendiente)
	animation_tree_quaternius.set(
		"parameters/conditions/inicio_aereo",
		en_el_aire and velocity.y > 0.0 and tiempo_aire_animacion >= TIEMPO_INICIO_SALTO_ANIMACION
	)
	animation_tree_quaternius.set(
		"parameters/conditions/descendiendo",
		en_el_aire and velocity.y <= 0.0
	)
	animation_tree_quaternius.set(
		"parameters/conditions/aterrizado",
		not en_el_aire and tiempo_aterrizaje > 0.0
	)
	if playback_animacion_quaternius != null and playback_animacion_quaternius.get_current_node() == &"SaltoInicio":
		salto_animacion_pendiente = false


func _orientar_visual_quaternius(delta: float) -> void:
	var velocidad_horizontal := Vector2(velocity.x, velocity.z)
	if velocidad_horizontal.length() < 0.12:
		return

	# El frente del rig Quaternius es +Z; se orienta solo el visual, no Modelo ni la fisica.
	var yaw_movimiento := atan2(-velocity.x, -velocity.z)
	var yaw_visual_deseado := wrapf(yaw_movimiento + PI - modelo.global_rotation.y, -PI, PI)
	visual_quaternius.rotation.y = lerp_angle(
		visual_quaternius.rotation.y,
		yaw_visual_deseado,
		minf(delta * 12.0, 1.0)
	)
