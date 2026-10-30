extends CharacterBody3D
## Caballero low-poly controlable: movimiento, salto, sprint y animacion simple.

const VELOCIDAD := 6.0
const VELOCIDAD_CORRER := 10.0
const ACELERACION := 16.0
const GRAVEDAD := 24.0
const SALTO := 8.0

var camara
@onready var modelo: Node3D = $Modelo
@onready var pierna_izq: Node3D = $Modelo/PiernaIzq
@onready var pierna_der: Node3D = $Modelo/PiernaDer
@onready var brazo_izq: Node3D = $Modelo/BrazoIzq
@onready var brazo_der: Node3D = $Modelo/BrazoDer
@onready var capa: MeshInstance3D = $Modelo/Capa

var tiempo := 0.0
var tiempo_paso := 0.0

func _physics_process(delta: float) -> void:
	tiempo += delta

	if not is_on_floor():
		velocity.y -= GRAVEDAD * delta
		velocity.y = maxf(velocity.y, -45.0)
	elif velocity.y < 0.0:
		velocity.y = 0.0

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = SALTO

	var entrada := Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		entrada.y += 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		entrada.y -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		entrada.x += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		entrada.x -= 1.0

	var yaw := 0.0
	if camara:
		yaw = camara.yaw
	var adelante := Vector3(-sin(yaw), 0.0, -cos(yaw))
	var derecha := Vector3(cos(yaw), 0.0, -sin(yaw))
	var direccion := adelante * entrada.y + derecha * entrada.x
	if direccion.length() > 1.0:
		direccion = direccion.normalized()

	var rapidez := VELOCIDAD
	if Input.is_key_pressed(KEY_SHIFT):
		rapidez = VELOCIDAD_CORRER

	var deseada := direccion * rapidez
	velocity.x = move_toward(velocity.x, deseada.x, ACELERACION * delta)
	velocity.z = move_toward(velocity.z, deseada.z, ACELERACION * delta)

	move_and_slide()

	if direccion.length() > 0.15:
		var objetivo := atan2(-direccion.x, -direccion.z)
		modelo.rotation.y = lerp_angle(modelo.rotation.y, objetivo, 12.0 * delta)

	_animar(delta)

func _animar(delta: float) -> void:
	var rapidez := Vector2(velocity.x, velocity.z).length()
	var amplitud := clampf(rapidez / VELOCIDAD, 0.0, 1.6)
	tiempo_paso += delta * (4.0 + rapidez * 1.4)
	var balanceo := sin(tiempo_paso) * 0.65 * amplitud

	pierna_izq.rotation.x = balanceo
	pierna_der.rotation.x = -balanceo
	brazo_izq.rotation.x = -balanceo * 0.8
	brazo_der.rotation.x = balanceo * 0.8

	var quieto := 1.0 - clampf(rapidez / VELOCIDAD, 0.0, 1.0)
	modelo.position.y = sin(tiempo * 2.2) * 0.015 * quieto

	if capa:
		capa.rotation.x = -0.06 + sin(tiempo * 3.0) * 0.03 + clampf(rapidez * 0.02, 0.0, 0.18)
