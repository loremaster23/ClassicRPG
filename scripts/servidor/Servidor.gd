
extends Node

const PUERTO := 9000
const MAX_JUGADORES := 2
const TIEMPO_RECHAZO := 0.5

const VELOCIDAD_MAXIMA := 10.0
const VELOCIDAD_NORMAL := 6.0
const ACELERACION := 16.0

const ALTURA_BASE_JUGADOR := 0.6
const ALTURA_MAXIMA_SALTO := 1.8
const TOLERANCIA_ALTURA_INFERIOR := 1.0

const GRAVEDAD := 24.0
const VELOCIDAD_SALTO := 8.0
const VELOCIDAD_CAIDA_MAXIMA := 45.0

const PRESUPUESTO_MOVIMIENTO_INICIAL := 0.3
const PRESUPUESTO_MOVIMIENTO_MAXIMO := 3.0
const TIEMPO_MAXIMO_ACUMULABLE := 0.5

const TOLERANCIA_VELOCIDAD_ASCENSO := 0.35
const TOLERANCIA_VELOCIDAD_DESCENSO := 0.5

const GeneradorTerreno := preload("res://scripts/compartido/GeneradorTerreno.gd")

var servidor := WebSocketMultiplayerPeer.new()
var jugadores: Dictionary = {}
var entidades: Dictionary = {}
var siguiente_id_entidad := 1
var rechazos_pendientes: Dictionary = {}

var ruido_terreno: FastNoiseLite
var ruido_detalle: FastNoiseLite

var arboles: Array[Dictionary] = []
var rocas: Array[Dictionary] = []


func _ready() -> void:
	_inicializar_mundo()

	servidor.peer_connected.connect(_al_conectar)
	servidor.peer_disconnected.connect(_al_desconectar)

	var error := servidor.create_server(PUERTO, "*")

	if error != OK:
		push_error("No se pudo iniciar el servidor: %s" % error)
		set_process(false)
		return

	print("Servidor iniciado. Máximo de jugadores: ", MAX_JUGADORES)


func _inicializar_mundo() -> void:
	ruido_terreno = GeneradorTerreno.crear_ruido_terreno()
	ruido_detalle = GeneradorTerreno.crear_ruido_detalle()

	arboles = GeneradorTerreno.generar_arboles()
	rocas = GeneradorTerreno.generar_rocas()


	_registrar_entidad("prueba", Vector3(0.0, _altura_terreno(0.0, 0.0) + 0.5, 0.0), "Entidad de prueba")
	_registrar_entidad("npc", Vector3(3.0, _altura_terreno(3.0, 0.0), 0.0), "Habitante")
	print("Mundo compartido inicializado.")
	print("Árboles generados: ", arboles.size())
	print("Rocas generadas: ", rocas.size())


func _altura_terreno(x: float, z: float) -> float:
	return GeneradorTerreno.altura(
		x,
		z,
		ruido_terreno,
		ruido_detalle
	)


func _obtener_slot_aparicion() -> int:
	var ocupados: Array[int] = []

	for estado in jugadores.values():
		var slot := int(estado.get("spawn_slot", -1))

		if slot >= 0:
			ocupados.append(slot)

	for slot in range(MAX_JUGADORES):
		if not ocupados.has(slot):
			return slot

	return 0


func _datos_mundo() -> Dictionary:
	return {
		"version": 1,
		"tamano": GeneradorTerreno.TAMANO_MUNDO,
		"resolucion": GeneradorTerreno.RESOLUCION,
		"semilla_terreno": GeneradorTerreno.SEMILLA_TERRENO,
		"semilla_detalle": GeneradorTerreno.SEMILLA_DETALLE,
		"semilla_arboles": GeneradorTerreno.SEMILLA_ARBOLES,
		"semilla_rocas": GeneradorTerreno.SEMILLA_ROCAS,
		"cantidad_arboles": arboles.size(),
		"cantidad_rocas": rocas.size()
	}


func _lista_entidades() -> Array:
	var lista: Array = []

	for id_var in entidades.keys():
		var entidad: Dictionary = entidades[id_var]
		lista.append(entidad.duplicate(true))

	return lista


func _registrar_entidad(tipo: String, posicion: Vector3, nombre: String = "") -> int:
	var id := siguiente_id_entidad
	siguiente_id_entidad += 1

	var entidad := {
		"id": id,
		"type": tipo,
		"name": nombre,
		"x": posicion.x,
		"y": posicion.y,
		"z": posicion.z
	}

	entidades[id] = entidad

	if not jugadores.is_empty():
		_difundir({
			"type": "entity_spawned",
			"entity": entidad
		})

	print("Entidad registrada: ", id, " | ", tipo)
	return id


func _eliminar_entidad(id: int) -> void:
	if not entidades.has(id):
		return

	entidades.erase(id)

	_difundir({
		"type": "entity_removed",
		"id": id
	})

	print("Entidad eliminada: ", id)

func _process(delta: float) -> void:
	servidor.poll()

	for id_var in rechazos_pendientes.keys():
		var id := int(id_var)
		rechazos_pendientes[id] -= delta

		if rechazos_pendientes[id] <= 0.0:
			if servidor.get_peer(id) != null:
				servidor.disconnect_peer(id)

			rechazos_pendientes.erase(id)

	while servidor.get_available_packet_count() > 0:
		var id := servidor.get_packet_peer()
		var mensaje := servidor.get_packet().get_string_from_utf8()

		if not jugadores.has(id):
			continue

		var datos = JSON.parse_string(mensaje)

		if typeof(datos) != TYPE_DICTIONARY:
			continue

		if datos.get("type", "") == "move":
			_procesar_movimiento(id, datos)


func _al_conectar(id: int) -> void:
	if jugadores.size() >= MAX_JUGADORES:
		print("Servidor lleno. Rechazando jugador: ", id)

		_enviar_texto(id, "SERVIDOR_LLENO")
		rechazos_pendientes[id] = TIEMPO_RECHAZO
		return

	var spawn_slot := _obtener_slot_aparicion()

	var posicion := GeneradorTerreno.posicion_aparicion(
		spawn_slot,
		ruido_terreno,
		ruido_detalle
	)

	var altura_base := _altura_terreno(
		posicion.x,
		posicion.z
	) + ALTURA_BASE_JUGADOR

	jugadores[id] = {
		"x": posicion.x,
		"y": posicion.y,
		"z": posicion.z,
		"yaw": 0.0,
		"sprint": false,
		"en_el_aire": false,
		"spawn_slot": spawn_slot,
		"ultimo_movimiento_ms": Time.get_ticks_msec(),
		"ultima_secuencia": -1,
		"presupuesto_movimiento": PRESUPUESTO_MOVIMIENTO_INICIAL,
		"altura_relativa": posicion.y - altura_base
	}

	var lista_jugadores: Array = []

	for otro_id in jugadores.keys():
		if int(otro_id) == id:
			continue

		var estado: Dictionary = jugadores[otro_id]

		lista_jugadores.append({
			"id": int(otro_id),
			"x": estado["x"],
			"y": estado["y"],
			"z": estado["z"],
			"yaw": estado["yaw"],
			"sprint": estado["sprint"],
			"en_el_aire": estado["en_el_aire"]
		})

	_enviar(id, {
		"type": "welcome",
		"id": id,
		"x": posicion.x,
		"y": posicion.y,
		"z": posicion.z,
		"yaw": 0.0,
		"players": lista_jugadores,
		"world": _datos_mundo(),
		"entities": _lista_entidades()
	})

	_difundir({
		"type": "player_joined",
		"id": id,
		"x": posicion.x,
		"y": posicion.y,
		"z": posicion.z,
		"yaw": 0.0,
		"sprint": false,
		"en_el_aire": false
	}, id)

	print("Jugador conectado: ", id, " | ", jugadores.size(), "/", MAX_JUGADORES)


func _procesar_movimiento(id: int, datos: Dictionary) -> void:
	if not jugadores.has(id):
		return

	var secuencia := int(datos.get("seq", -1))

	var estado: Dictionary = jugadores[id]

	if secuencia < 0:
		_corregir_posicion(id, secuencia)
		return

	if secuencia <= int(estado["ultima_secuencia"]):
		return

	var x := float(datos.get("x", 0.0))
	var y := float(datos.get("y", 0.6))
	var z := float(datos.get("z", 10.0))
	var yaw := float(datos.get("yaw", 0.0))

	var sprint := bool(datos.get("sprint", false))
	var en_el_aire := bool(datos.get("en_el_aire", false))

	if not is_finite(x) or not is_finite(y) or not is_finite(z) or not is_finite(yaw):
		_corregir_posicion(id, secuencia)
		return

	if x < -55.0 or x > 55.0 or z < -55.0 or z > 55.0:
		_corregir_posicion(id, secuencia)
		return

	if y < -5.0 or y > 30.0:
		_corregir_posicion(id, secuencia)
		return

	var posicion_anterior := Vector3(
		float(estado["x"]),
		float(estado["y"]),
		float(estado["z"])
	)

	var posicion_nueva := Vector3(x, y, z)

	var distancia_horizontal := Vector2(
		x - posicion_anterior.x,
		z - posicion_anterior.z
	).length()

	var ahora_ms := Time.get_ticks_msec()
	var anterior_ms := int(estado["ultimo_movimiento_ms"])

	var tiempo_real := maxf(
		float(ahora_ms - anterior_ms) / 1000.0,
		0.0
	)

	var tiempo_validacion := minf(
		tiempo_real,
		TIEMPO_MAXIMO_ACUMULABLE
	)

	var velocidad_permitida := (
		VELOCIDAD_MAXIMA if sprint else VELOCIDAD_NORMAL
	)

	var presupuesto := minf(
		float(estado["presupuesto_movimiento"])
		+ velocidad_permitida * tiempo_validacion,
		PRESUPUESTO_MOVIMIENTO_MAXIMO
	)

	if distancia_horizontal > presupuesto:
		_corregir_posicion(id, secuencia)
		return

	var altura_terreno := _altura_terreno(x, z)
	var altura_base := altura_terreno + ALTURA_BASE_JUGADOR

	var altura_relativa := y - altura_base
	var altura_anterior := float(estado["altura_relativa"])

	if altura_relativa < -TOLERANCIA_ALTURA_INFERIOR:
		_corregir_posicion(id, secuencia)
		return

	if altura_relativa > ALTURA_MAXIMA_SALTO:
		_corregir_posicion(id, secuencia)
		return

	var desplazamiento_vertical := altura_relativa - altura_anterior

	var ascenso_permitido := (
		VELOCIDAD_SALTO * tiempo_validacion
		+ TOLERANCIA_VELOCIDAD_ASCENSO
	)

	var descenso_permitido := (
		VELOCIDAD_CAIDA_MAXIMA * tiempo_validacion
		+ TOLERANCIA_VELOCIDAD_DESCENSO
	)

	if desplazamiento_vertical > ascenso_permitido:
		_corregir_posicion(id, secuencia)
		return

	if desplazamiento_vertical < -descenso_permitido:
		_corregir_posicion(id, secuencia)
		return

	jugadores[id] = {
		"x": posicion_nueva.x,
		"y": posicion_nueva.y,
		"z": posicion_nueva.z,
		"yaw": yaw,
		"sprint": sprint,
		"en_el_aire": en_el_aire,
		"spawn_slot": int(estado["spawn_slot"]),
		"ultimo_movimiento_ms": ahora_ms,
		"ultima_secuencia": secuencia,
		"presupuesto_movimiento": presupuesto - distancia_horizontal,
		"altura_relativa": altura_relativa
	}

	_difundir({
		"type": "move",
		"id": id,
		"x": x,
		"y": y,
		"z": z,
		"yaw": yaw,
		"sprint": sprint,
		"en_el_aire": en_el_aire
	}, id)


func _corregir_posicion(id: int, secuencia: int = -1) -> void:
	if not jugadores.has(id):
		return

	var estado: Dictionary = jugadores[id]

	_enviar(id, {
		"type": "position_correction",
		"seq": secuencia,
		"x": estado["x"],
		"y": estado["y"],
		"z": estado["z"],
		"yaw": estado["yaw"],
		"sprint": estado["sprint"],
		"en_el_aire": estado["en_el_aire"]
	})


func _al_desconectar(id: int) -> void:
	if jugadores.has(id):
		jugadores.erase(id)

		_difundir({
			"type": "player_left",
			"id": id
		})

		print("Jugador desconectado: ", id, " | ", jugadores.size(), "/", MAX_JUGADORES)

	rechazos_pendientes.erase(id)


func _enviar(id: int, datos: Dictionary) -> void:
	servidor.set_target_peer(id)

	var error := servidor.put_packet(
		JSON.stringify(datos).to_utf8_buffer()
	)

	servidor.set_target_peer(MultiplayerPeer.TARGET_PEER_BROADCAST)

	if error != OK:
		push_error("Error enviando datos al jugador: %s" % id)


func _enviar_texto(id: int, mensaje: String) -> void:
	servidor.set_target_peer(id)

	var error := servidor.put_packet(mensaje.to_utf8_buffer())

	servidor.set_target_peer(MultiplayerPeer.TARGET_PEER_BROADCAST)

	if error != OK:
		push_error("Error enviando rechazo al jugador: %s" % id)


func _difundir(datos: Dictionary, excluir_id: int = -1) -> void:
	for id_var in jugadores.keys():
		var id := int(id_var)

		if id != excluir_id:
			_enviar(id, datos)


func _exit_tree() -> void:
	servidor.close()
