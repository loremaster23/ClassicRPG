extends CharacterBody3D
## Caballero low-poly controlable: movimiento, salto, sprint y animacion simple.

const VELOCIDAD := 6.0
const VELOCIDAD_CORRER := 10.0
const ACELERACION := 16.0
const GRAVEDAD := 24.0
const SALTO := 8.0

var camara
var modelo: Node3D
var pierna_izq: Node3D
var pierna_der: Node3D
var brazo_izq: Node3D
var brazo_der: Node3D
var capa: MeshInstance3D

var tiempo := 0.0
var tiempo_paso := 0.0

func _ready() -> void:
	_crear_colision()
	_crear_modelo()

func _crear_colision() -> void:
	var forma := CollisionShape3D.new()
	var capsula := CapsuleShape3D.new()
	capsula.radius = 0.42
	capsula.height = 1.8
	forma.shape = capsula
	forma.position.y = 0.9
	add_child(forma)

func _c(r: float, g: float, b: float) -> Color:
	return Color(r, g, b).srgb_to_linear()

func _mat(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 1.0
	m.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	return m

func _caja(tam: Vector3, pos: Vector3, color: Color, padre: Node3D) -> MeshInstance3D:
	var nodo := MeshInstance3D.new()
	var malla := BoxMesh.new()
	malla.size = tam
	nodo.mesh = malla
	nodo.position = pos
	nodo.material_override = _mat(color)
	padre.add_child(nodo)
	return nodo

func _esfera(radio: float, pos: Vector3, color: Color, padre: Node3D) -> MeshInstance3D:
	var nodo := MeshInstance3D.new()
	var malla := SphereMesh.new()
	malla.radius = radio
	malla.height = radio * 2.0
	malla.radial_segments = 12
	malla.rings = 6
	nodo.mesh = malla
	nodo.position = pos
	nodo.material_override = _mat(color)
	padre.add_child(nodo)
	return nodo

func _crear_modelo() -> void:
	modelo = Node3D.new()
	add_child(modelo)

	var acero := _c(0.62, 0.66, 0.72)
	var acero_oscuro := _c(0.38, 0.42, 0.48)
	var tela := _c(0.16, 0.26, 0.55)
	var cuero := _c(0.32, 0.20, 0.11)
	var piel := _c(0.86, 0.66, 0.50)
	var dorado := _c(0.85, 0.68, 0.28)
	var rojo := _c(0.55, 0.10, 0.10)

	# Torso y armadura
	_caja(Vector3(0.84, 0.88, 0.52), Vector3(0, 1.38, 0), tela, modelo)
	_caja(Vector3(0.66, 0.52, 0.12), Vector3(0, 1.48, -0.28), acero, modelo)
	_caja(Vector3(0.94, 0.16, 0.60), Vector3(0, 0.97, 0), cuero, modelo)
	_caja(Vector3(0.20, 0.18, 0.10), Vector3(0, 0.97, -0.31), dorado, modelo)

	# Piernas
	pierna_izq = Node3D.new()
	pierna_izq.position = Vector3(-0.23, 0.95, 0)
	modelo.add_child(pierna_izq)
	_caja(Vector3(0.28, 0.85, 0.32), Vector3(0, -0.425, 0), tela, pierna_izq)
	_caja(Vector3(0.30, 0.18, 0.42), Vector3(0, -0.86, -0.04), cuero, pierna_izq)

	pierna_der = Node3D.new()
	pierna_der.position = Vector3(0.23, 0.95, 0)
	modelo.add_child(pierna_der)
	_caja(Vector3(0.28, 0.85, 0.32), Vector3(0, -0.425, 0), tela, pierna_der)
	_caja(Vector3(0.30, 0.18, 0.42), Vector3(0, -0.86, -0.04), cuero, pierna_der)

	# Brazos
	brazo_izq = Node3D.new()
	brazo_izq.position = Vector3(-0.56, 1.66, 0)
	modelo.add_child(brazo_izq)
	_caja(Vector3(0.22, 0.70, 0.24), Vector3(0, -0.35, 0), tela, brazo_izq)
	_caja(Vector3(0.20, 0.20, 0.22), Vector3(0, -0.75, 0), piel, brazo_izq)

	brazo_der = Node3D.new()
	brazo_der.position = Vector3(0.56, 1.66, 0)
	modelo.add_child(brazo_der)
	_caja(Vector3(0.22, 0.70, 0.24), Vector3(0, -0.35, 0), tela, brazo_der)
	_caja(Vector3(0.20, 0.20, 0.22), Vector3(0, -0.75, 0), piel, brazo_der)

	# Hombreras
	_esfera(0.26, Vector3(-0.58, 1.80, 0), acero, modelo)
	_esfera(0.26, Vector3(0.58, 1.80, 0), acero, modelo)

	# Cabeza con casco abierto
	_esfera(0.27, Vector3(0, 2.03, 0), acero, modelo)
	_caja(Vector3(0.30, 0.20, 0.12), Vector3(0, 1.99, -0.22), piel, modelo)
	_caja(Vector3(0.07, 0.24, 0.06), Vector3(0, 2.01, -0.29), acero_oscuro, modelo)
	_caja(Vector3(0.05, 0.04, 0.03), Vector3(-0.09, 2.01, -0.285), Color(0.05, 0.05, 0.05), modelo)
	_caja(Vector3(0.05, 0.04, 0.03), Vector3(0.09, 2.01, -0.285), Color(0.05, 0.05, 0.05), modelo)

	# Capa
	capa = _caja(Vector3(0.74, 1.10, 0.06), Vector3(0, 1.28, 0.31), rojo, modelo)

	# Espada a la espalda
	var espada := Node3D.new()
	espada.position = Vector3(0.20, 1.45, 0.36)
	espada.rotation = Vector3(0.0, 0.0, deg_to_rad(30.0))
	modelo.add_child(espada)
	_caja(Vector3(0.09, 1.10, 0.05), Vector3(0, 0.32, 0), acero, espada)
	_caja(Vector3(0.36, 0.07, 0.08), Vector3(0, -0.24, 0), dorado, espada)
	_caja(Vector3(0.07, 0.26, 0.07), Vector3(0, -0.41, 0), cuero, espada)

	# Escudo en el brazo izquierdo
	var escudo := MeshInstance3D.new()
	var malla_escudo := CylinderMesh.new()
	malla_escudo.top_radius = 0.34
	malla_escudo.bottom_radius = 0.34
	malla_escudo.height = 0.08
	malla_escudo.radial_segments = 12
	escudo.mesh = malla_escudo
	escudo.rotation_degrees = Vector3(0, 0, 90)
	escudo.position = Vector3(-0.17, -0.36, 0)
	escudo.material_override = _mat(cuero)
	brazo_izq.add_child(escudo)
	_esfera(0.09, Vector3(-0.22, -0.36, 0), acero, brazo_izq)

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
