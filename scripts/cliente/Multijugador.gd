
extends Node

const DIRECCION := "ws://127.0.0.1:9000"
const EscenaJugador := preload("res://Personajes/Jugador.tscn")
const IMAGEN_SERVIDOR_LLENO := preload("res://assets/ui/servidor_lleno.png")
const GeneradorTerreno := preload("res://scripts/compartido/GeneradorTerreno.gd")
const FabricaEntidades := preload("res://scripts/cliente/FabricaEntidades.gd")

const DISTANCIA_CORRECCION_BRUSCA := 3.0
const VELOCIDAD_CORRECCION := 10.0
const UMBRAL_CORRECCION := 0.025

var cliente := WebSocketMultiplayerPeer.new()
var jugador_local: CharacterBody3D
var id_local := 0
var conectado := false
var rechazo_servidor := false
var tiempo_envio := 0.0

var secuencia_movimiento := 0
var ultima_secuencia_correccion := -1

var correccion_pendiente := false
var objetivo_correccion := Vector3.ZERO
var yaw_correccion := 0.0

var jugadores_remotos: Dictionary = {}
var objetivos_remotos: Dictionary = {}
var entidades_remotas: Dictionary = {}

var mundo_validado := false
var configuracion_mundo: Dictionary = {}


func iniciar(jugador: CharacterBody3D) -> void:
	jugador_local = jugador

	var error := cliente.create_client(DIRECCION)

	if error != OK:
		push_error("Error al conectar con el servidor: %s" % error)
		return

	print("Conectando al servidor multijugador...")


func _process(delta: float) -> void:
	cliente.poll()

	while cliente.get_available_packet_count() > 0:
		var mensaje := cliente.get_packet().get_string_from_utf8()

		if mensaje == "SERVIDOR_LLENO":
			if not rechazo_servidor:
				rechazo_servidor = true
				_mostrar_servidor_lleno()
			continue

		if rechazo_servidor:
			continue

		var datos = JSON.parse_string(mensaje)

		if typeof(datos) != TYPE_DICTIONARY:
			continue

		_procesar_mensaje(datos)

	if rechazo_servidor:
		return

	if cliente.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		if not conectado:
			conectado = true
			print("Conexión multijugador establecida.")

		if id_local != 0:
			tiempo_envio += delta

			if tiempo_envio >= 0.1:
				tiempo_envio = 0.0
				_enviar_posicion()

	_actualizar_remotos(delta)
	_actualizar_correccion_local(delta)


func _procesar_mensaje(datos: Dictionary) -> void:
	match datos.get("type", ""):
		"welcome":
			id_local = int(datos.get("id", 0))
			print("Identificado en el servidor. ID: ", id_local)

			_validar_mundo(datos.get("world", {}))

			if jugador_local != null:
				jugador_local.global_position = _leer_posicion(datos)
				jugador_local.velocity = Vector3.ZERO

				var modelo: Node3D = jugador_local.get_node("Modelo")
				modelo.rotation.y = float(datos.get("yaw", 0.0))

			for jugador in datos.get("players", []):
				if typeof(jugador) == TYPE_DICTIONARY:
					_crear_remoto(
						int(jugador.get("id", 0)),
						_leer_posicion(jugador),
						float(jugador.get("yaw", 0.0)),
						bool(jugador.get("sprint", false)),
						bool(jugador.get("en_el_aire", false))
					)

			for entidad in datos.get("entities", []):
				if typeof(entidad) == TYPE_DICTIONARY:
					_crear_entidad_remota(entidad)

		"player_joined":
			var id := int(datos.get("id", 0))
			print("Jugador conectado: ", id)

			_crear_remoto(
				id,
				_leer_posicion(datos),
				float(datos.get("yaw", 0.0)),
				bool(datos.get("sprint", false)),
				bool(datos.get("en_el_aire", false))
			)

		"move":
			var id := int(datos.get("id", 0))

			if id != id_local and jugadores_remotos.has(id):
				_actualizar_objetivo(
					id,
					_leer_posicion(datos),
					float(datos.get("yaw", 0.0)),
					bool(datos.get("sprint", false)),
					bool(datos.get("en_el_aire", false))
				)

		"position_correction":
			_aplicar_correccion(datos)

		"entity_spawned":
			var entidad = datos.get("entity", {})
			if typeof(entidad) == TYPE_DICTIONARY:
				_crear_entidad_remota(entidad)

		"entity_removed":
			_eliminar_entidad_remota(int(datos.get("id", 0)))

		"player_left":
			var id := int(datos.get("id", 0))
			_eliminar_remoto(id)
			print("Jugador desconectado: ", id)


func _aplicar_correccion(datos: Dictionary) -> void:
	if not is_instance_valid(jugador_local):
		return

	var secuencia := int(datos.get("seq", -1))

	if secuencia >= 0:
		if secuencia < ultima_secuencia_correccion:
			return

		ultima_secuencia_correccion = secuencia

	var posicion := _leer_posicion(datos)
	var distancia := jugador_local.global_position.distance_to(posicion)

	yaw_correccion = float(datos.get("yaw", 0.0))

	if distancia >= DISTANCIA_CORRECCION_BRUSCA:
		jugador_local.global_position = posicion
		jugador_local.velocity = Vector3.ZERO
		correccion_pendiente = false
	else:
		objetivo_correccion = posicion
		correccion_pendiente = distancia > UMBRAL_CORRECCION

	if not correccion_pendiente:
		var modelo: Node3D = jugador_local.get_node("Modelo")
		modelo.rotation.y = yaw_correccion


func _actualizar_correccion_local(delta: float) -> void:
	if not correccion_pendiente:
		return

	if not is_instance_valid(jugador_local):
		correccion_pendiente = false
		return

	var distancia := jugador_local.global_position.distance_to(
		objetivo_correccion
	)

	if distancia <= UMBRAL_CORRECCION:
		jugador_local.global_position = objetivo_correccion
		correccion_pendiente = false
	else:
		jugador_local.global_position = jugador_local.global_position.lerp(
			objetivo_correccion,
			minf(delta * VELOCIDAD_CORRECCION, 1.0)
		)

	var modelo: Node3D = jugador_local.get_node("Modelo")
	modelo.rotation.y = lerp_angle(
		modelo.rotation.y,
		yaw_correccion,
		minf(delta * VELOCIDAD_CORRECCION, 1.0)
	)


func _validar_mundo(datos: Variant) -> void:
	mundo_validado = false
	configuracion_mundo.clear()

	if typeof(datos) != TYPE_DICTIONARY:
		push_error("El servidor no envió una configuración válida del mundo.")
		return

	var esperado := {
		"version": 1,
		"tamano": GeneradorTerreno.TAMANO_MUNDO,
		"resolucion": GeneradorTerreno.RESOLUCION,
		"semilla_terreno": GeneradorTerreno.SEMILLA_TERRENO,
		"semilla_detalle": GeneradorTerreno.SEMILLA_DETALLE,
		"semilla_arboles": GeneradorTerreno.SEMILLA_ARBOLES,
		"semilla_rocas": GeneradorTerreno.SEMILLA_ROCAS,
		"cantidad_arboles": GeneradorTerreno.generar_arboles().size(),
		"cantidad_rocas": GeneradorTerreno.generar_rocas().size()
	}

	var diferencias: Array[String] = []

	for clave in esperado.keys():
		if not datos.has(clave):
			diferencias.append("Falta el dato: " + str(clave))
		elif datos[clave] != esperado[clave]:
			diferencias.append(
				"%s: servidor=%s, cliente=%s" % [
					clave,
					str(datos[clave]),
					str(esperado[clave])
				]
			)

	if not diferencias.is_empty():
		push_error("El mundo del servidor no coincide con el cliente.")

		for diferencia in diferencias:
			push_error(diferencia)

		return

	configuracion_mundo = datos.duplicate(true)
	mundo_validado = true

	print("Mundo compartido validado correctamente.")
	print("Árboles locales: ", esperado["cantidad_arboles"])
	print("Rocas locales: ", esperado["cantidad_rocas"])
	print("Semillas y dimensiones coincidentes.")


func _leer_posicion(datos: Dictionary) -> Vector3:
	return Vector3(
		float(datos.get("x", 0.0)),
		float(datos.get("y", 0.6)),
		float(datos.get("z", 10.0))
	)


func _crear_remoto(
	id: int,
	posicion: Vector3,
	yaw: float,
	sprint: bool = false,
	en_el_aire: bool = false
) -> void:
	if id == 0 or id == id_local or jugadores_remotos.has(id):
		return

	var remoto = EscenaJugador.instantiate()
	remoto.es_local = false

	get_parent().add_child(remoto)
	remoto.global_position = posicion
	remoto.set_physics_process(false)

	var colision := remoto.get_node_or_null("Colision") as CollisionShape3D

	if colision:
		colision.set_deferred("disabled", true)

	var modelo: Node3D = remoto.get_node("Modelo")
	modelo.rotation.y = yaw

	remoto.en_el_aire = en_el_aire
	remoto.corriendo = sprint

	jugadores_remotos[id] = remoto

	objetivos_remotos[id] = {
		"pos": posicion,
		"yaw": yaw,
		"sprint": sprint,
		"en_el_aire": en_el_aire
	}

	print("Personaje remoto creado: ", id)


func _crear_entidad_remota(datos: Dictionary) -> void:
	var id := int(datos.get("id", 0))
	var tipo := str(datos.get("type", ""))

	if id <= 0 or entidades_remotas.has(id):
		return

	var posicion := _leer_posicion(datos)

	if not is_finite(posicion.x) or not is_finite(posicion.y) or not is_finite(posicion.z):
		return

	var entidad := FabricaEntidades.crear(tipo, id, str(datos.get("name", "")))

	if entidad == null:
		return

	get_parent().add_child(entidad)
	entidad.global_position = posicion
	entidades_remotas[id] = entidad

	print("Entidad remota creada: ", id, " | ", tipo)

func _eliminar_entidad_remota(id: int) -> void:
	if not entidades_remotas.has(id):
		return

	var entidad = entidades_remotas[id]

	if is_instance_valid(entidad):
		entidad.queue_free()

	entidades_remotas.erase(id)
	print("Entidad remota eliminada: ", id)

func _actualizar_objetivo(
	id: int,
	posicion: Vector3,
	yaw: float,
	sprint: bool,
	en_el_aire: bool
) -> void:
	objetivos_remotos[id] = {
		"pos": posicion,
		"yaw": yaw,
		"sprint": sprint,
		"en_el_aire": en_el_aire
	}


func _actualizar_remotos(delta: float) -> void:
	for id_var in jugadores_remotos.keys():
		var id := int(id_var)
		var remoto = jugadores_remotos[id]

		if not is_instance_valid(remoto):
			continue

		if not objetivos_remotos.has(id):
			continue

		var objetivo: Dictionary = objetivos_remotos[id]

		remoto.corriendo = bool(objetivo.get("sprint", false))
		remoto.en_el_aire = bool(objetivo.get("en_el_aire", false))

		var anterior: Vector3 = remoto.global_position

		remoto.global_position = remoto.global_position.lerp(
			objetivo["pos"],
			minf(delta * 12.0, 1.0)
		)

		remoto.velocity = (
			remoto.global_position - anterior
		) / maxf(delta, 0.0001)

		var modelo: Node3D = remoto.get_node("Modelo")

		modelo.rotation.y = lerp_angle(
			modelo.rotation.y,
			float(objetivo["yaw"]),
			minf(delta * 12.0, 1.0)
		)

		remoto.call("_animar", delta)


func _enviar_posicion() -> void:
	if not is_instance_valid(jugador_local):
		return

	var posicion := jugador_local.global_position
	var modelo: Node3D = jugador_local.get_node("Modelo")

	secuencia_movimiento += 1

	var paquete := {
		"type": "move",
		"seq": secuencia_movimiento,
		"x": posicion.x,
		"y": posicion.y,
		"z": posicion.z,
		"yaw": modelo.rotation.y,
		"sprint": jugador_local.corriendo,
		"en_el_aire": jugador_local.en_el_aire
	}

	var error := cliente.put_packet(
		JSON.stringify(paquete).to_utf8_buffer()
	)

	if error != OK:
		push_error("Error enviando posición al servidor: %s" % error)


func _eliminar_remoto(id: int) -> void:
	if jugadores_remotos.has(id):
		var remoto = jugadores_remotos[id]

		if is_instance_valid(remoto):
			remoto.queue_free()

		jugadores_remotos.erase(id)

	objetivos_remotos.erase(id)


func _mostrar_servidor_lleno() -> void:
	print("Servidor lleno. Mostrando pantalla de rechazo.")

	conectado = false
	id_local = 0

	if is_instance_valid(jugador_local):
		jugador_local.queue_free()
		jugador_local = null

	for remoto in jugadores_remotos.values():
		if is_instance_valid(remoto):
			remoto.queue_free()

	jugadores_remotos.clear()
	objetivos_remotos.clear()
	for entidad in entidades_remotas.values():
		if is_instance_valid(entidad):
			entidad.queue_free()
	entidades_remotas.clear()

	var capa := CanvasLayer.new()
	capa.layer = 100
	get_tree().root.add_child(capa)

	var fondo := TextureRect.new()
	fondo.texture = IMAGEN_SERVIDOR_LLENO
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fondo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fondo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	fondo.mouse_filter = Control.MOUSE_FILTER_STOP

	capa.add_child(fondo)


func _exit_tree() -> void:
	cliente.close()
