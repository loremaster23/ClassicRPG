extends Node

const PUERTO := 9000
const MAX_JUGADORES := 2
const TIEMPO_RECHAZO := 0.5

var servidor := WebSocketMultiplayerPeer.new()
var jugadores: Dictionary = {}
var rechazos_pendientes: Dictionary = {}

func _ready() -> void:
	servidor.peer_connected.connect(_al_conectar)
	servidor.peer_disconnected.connect(_al_desconectar)

	var error := servidor.create_server(PUERTO, "*")
	if error != OK:
		push_error("No se pudo iniciar el servidor: %s" % error)
		set_process(false)
		return

	print("Servidor iniciado. Máximo de jugadores: ", MAX_JUGADORES)

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

	jugadores[id] = {
		"x": 0.0,
		"y": 0.6,
		"z": 10.0,
		"yaw": 0.0,
		"sprint": false,
		"en_el_aire": false
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
		"players": lista_jugadores
	})

	_difundir({
		"type": "player_joined",
		"id": id,
		"x": 0.0,
		"y": 0.6,
		"z": 10.0,
		"yaw": 0.0,
		"sprint": false,
		"en_el_aire": false
	}, id)

	print("Jugador conectado: ", id, " | ", jugadores.size(), "/", MAX_JUGADORES)

func _procesar_movimiento(id: int, datos: Dictionary) -> void:
	var x := clampf(float(datos.get("x", 0.0)), -55.0, 55.0)
	var y := clampf(float(datos.get("y", 0.6)), -5.0, 30.0)
	var z := clampf(float(datos.get("z", 10.0)), -55.0, 55.0)
	var yaw := float(datos.get("yaw", 0.0))
	var sprint := bool(datos.get("sprint", false))
	var en_el_aire := bool(datos.get("en_el_aire", false))

	jugadores[id] = {
		"x": x,
		"y": y,
		"z": z,
		"yaw": yaw,
		"sprint": sprint,
		"en_el_aire": en_el_aire
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