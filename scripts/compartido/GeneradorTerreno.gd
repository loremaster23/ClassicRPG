
extends RefCounted
## Generador compartido del mundo de ClassicRPG.
## El servidor y los clientes utilizan las mismas reglas y semillas.

const TAMANO_MUNDO: float = 110.0
const RESOLUCION: int = 44

const NUM_ARBOLES: int = 80
const NUM_ROCAS: int = 24

const SEMILLA_TERRENO: int = 20261030
const SEMILLA_DETALLE: int = 777

const SEMILLA_ARBOLES: int = 20261031
const SEMILLA_ROCAS: int = 20261032


static func crear_ruido_terreno() -> FastNoiseLite:
	var ruido := FastNoiseLite.new()
	ruido.seed = SEMILLA_TERRENO
	ruido.frequency = 0.022
	ruido.fractal_octaves = 3
	return ruido


static func crear_ruido_detalle() -> FastNoiseLite:
	var ruido := FastNoiseLite.new()
	ruido.seed = SEMILLA_DETALLE
	ruido.frequency = 0.06
	ruido.fractal_octaves = 2
	return ruido


static func altura(
	x: float,
	z: float,
	ruido: FastNoiseLite,
	ruido_detalle: FastNoiseLite
) -> float:
	var dist := Vector2(x, z).length() / (TAMANO_MUNDO * 0.5)
	var factor := smoothstep(0.22, 0.92, dist)

	var n := ruido.get_noise_2d(x, z) * 0.5 + 0.5
	var detalle := ruido_detalle.get_noise_2d(
		x * 2.5,
		z * 2.5
	) * 0.5 + 0.5

	var h := (n * 7.0 + detalle * 1.6) * factor

	var borde := smoothstep(0.78, 1.0, dist)
	h += borde * (8.0 + n * 10.0)

	var curva := sin(z * 0.11) * 3.0
	h *= smoothstep(3.0, 10.0, abs(x - curva))

	return h


static func posicion_aparicion(
	indice: int,
	ruido: FastNoiseLite,
	ruido_detalle: FastNoiseLite
) -> Vector3:
	var z := 8.0 + float(indice) * 6.0
	var x := sin(z * 0.11) * 3.0
	return Vector3(
		x,
		altura(x, z, ruido, ruido_detalle) + 0.6,
		z
	)

static func generar_arboles() -> Array[Dictionary]:
	var resultado: Array[Dictionary] = []
	var rng := RandomNumberGenerator.new()
	rng.seed = SEMILLA_ARBOLES

	var colocados := 0
	var intentos := 0

	while colocados < NUM_ARBOLES and intentos < NUM_ARBOLES * 20:
		intentos += 1

		var angulo := rng.randf() * TAU
		var radio := sqrt(rng.randf()) * (TAMANO_MUNDO * 0.46)

		var x := cos(angulo) * radio
		var z := sin(angulo) * radio

		var curva := sin(z * 0.11) * 3.0

		if abs(x - curva) < 6.0:
			continue

		if Vector2(x, z).length() < 10.0:
			continue

		resultado.append({
			"posicion": Vector3(x, 0.0, z),
			"escala": rng.randf_range(0.85, 1.45),
			"rotacion": rng.randf() * TAU
		})

		colocados += 1

	return resultado


static func generar_rocas() -> Array[Dictionary]:
	var resultado: Array[Dictionary] = []
	var rng := RandomNumberGenerator.new()
	rng.seed = SEMILLA_ROCAS

	for i in range(NUM_ROCAS):
		var angulo := rng.randf() * TAU
		var radio := rng.randf_range(12.0, TAMANO_MUNDO * 0.46)

		var x := cos(angulo) * radio
		var z := sin(angulo) * radio

		if abs(x - sin(z * 0.11) * 3.0) < 5.0:
			continue

		resultado.append({
			"posicion": Vector3(x, 0.0, z),
			"escala": Vector3(
				rng.randf_range(0.6, 1.7),
				rng.randf_range(0.5, 1.1),
				rng.randf_range(0.6, 1.7)
			),
			"rotacion": Vector3(
				0.0,
				rng.randf() * TAU,
				rng.randf_range(-0.15, 0.15)
			)
		})

	return resultado
