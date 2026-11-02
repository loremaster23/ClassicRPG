
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

const RANGO_ATAQUE_MELEE := 4.5
const TIEMPO_RECARGA_ATAQUE := 1.2
const TIEMPO_RECARGA_GOLPE_PESADO := 6.0
const MULTIPLICADOR_GOLPE_PESADO := 2
const DANIO_BASE_MELEE := 15
const DANIO_BONUS_POR_NIVEL := 2
const DANIO_POR_FUERZA := 2
const TIEMPO_RESPAWN := 6.0
const VIDA_MAXIMA_JUGADOR := 100
const VIDA_POR_VITALIDAD := 10
const DANIO_LOBO := 10
const RANGO_ATAQUE_LOBO := 2.5
const TIEMPO_RECARGA_LOBO := 1.5
const VIDA_MAXIMA_JABALI := 80
const DANIO_JABALI := 14
const RANGO_ATAQUE_JABALI := 2.6
const TIEMPO_RECARGA_JABALI := 2.0
const XP_POR_JABALI := 35
const VIDA_MAXIMA_LIMO := 45
const DANIO_LIMO := 8
const RANGO_ATAQUE_LIMO := 2.1
const TIEMPO_RECARGA_LIMO := 2.5
const XP_POR_LIMO := 20
const TIEMPO_RESPAWN_JUGADOR := 5.0
const PROTECCION_REAPARICION := 2.0
const XP_POR_LOBO := 25
const XP_PARA_SUBIR_NIVEL := 100
const RANGO_INTERACCION := 4.0
const LOBOS_REQUERIDOS_MISION := 3
const XP_RECOMPENSA_MISION := 50
const PIEL_LOBO_REQUERIDAS_ENTREGA := 3
const XP_RECOMPENSA_ENTREGA := 75
const CARNE_JABALI_REQUERIDA_MISION := 3
const XP_RECOMPENSA_ENTREGA_CARNE := 100
const JABALIES_REQUERIDOS_MISION := 3
const XP_RECOMPENSA_CAZA_JABALI := 60
const GELATINA_LIMO_REQUERIDA_MISION := 3
const XP_RECOMPENSA_ENTREGA_GELATINA := 120
const ORO_MAXIMO := 999999999
const ORO_RECOMPENSA_CAZA_LOBOS := 30
const ORO_RECOMPENSA_ENTREGA_PIELES := 15
const ORO_RECOMPENSA_ENTREGA_CARNE := 25
const ORO_RECOMPENSA_CAZA_JABALIES := 30
const ORO_RECOMPENSA_ENTREGA_GELATINA := 35

const GeneradorTerreno := preload("res://scripts/compartido/GeneradorTerreno.gd")
const CatalogoObjetos := preload("res://scripts/compartido/CatalogoObjetos.gd")

var servidor := WebSocketMultiplayerPeer.new()
var jugadores: Dictionary = {}
var entidades: Dictionary = {}
var inventarios: Dictionary = {}
var oro_jugadores: Dictionary = {}
var progresion_jugadores: Dictionary = {}
var salud_jugadores: Dictionary = {}
var misiones_jugadores: Dictionary = {}
var equipamiento_jugadores: Dictionary = {}
var modo_individual := false
var puerto_escucha := PUERTO
var ruta_guardado_local := "user://classicrpg_partida.json"
var tiempo_guardado_local := 0.0
const INTERVALO_GUARDADO_LOCAL := 10.0
var datos_spawn_jugadores: Dictionary = {}
var temporizadores_respawn_jugadores: Dictionary = {}
var proteccion_respawn_jugadores: Dictionary = {}
var tiempo_ataque_lobo := 0.0
var tiempo_ataque_jabali := 0.0
var tiempo_ataque_limo := 0.0
var siguiente_id_entidad := 1
var rechazos_pendientes: Dictionary = {}
var temporizadores_respawn: Dictionary = {}
var datos_spawn_original: Dictionary = {}

var ruido_terreno: FastNoiseLite
var ruido_detalle: FastNoiseLite

var arboles: Array[Dictionary] = []
var rocas: Array[Dictionary] = []
var tiempo_ia_entidades := 0.0
var paso_patrulla_lobo := 0
var tiempo_ia_jabali := 0.0
var paso_patrulla_jabali := 0
var tiempo_ia_limo := 0.0
var paso_patrulla_limo := 0
signal ataque_procesado(id_jugador: int, resultado: Dictionary)
var tiempos_ultimo_ataque: Dictionary = {}
var tiempos_ultimo_golpe_pesado: Dictionary = {}


func _ready() -> void:
	_inicializar_mundo()

	servidor.peer_connected.connect(_al_conectar)
	servidor.peer_disconnected.connect(_al_desconectar)

	var error := servidor.create_server(puerto_escucha, "*")

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


	_registrar_entidad("prueba", Vector3(0.0, _altura_terreno(0.0, 0.0) + 0.5, 0.0), "Entidad de prueba", 0.0, 100, 100, "activo")
	_registrar_entidad("npc", Vector3(3.0, _altura_terreno(3.0, 0.0), 0.0), "Habitante", 0.0, 100, 100, "idle")
	_registrar_entidad("lobo", Vector3(-3.0, _altura_terreno(-3.0, 0.0), 0.0), "Lobo del Bosque", 0.0, 60, 60, "patrullando")
	_registrar_entidad("jabali", Vector3(8.0, _altura_terreno(8.0, -8.0), -8.0), "Jabalí del Bosque", 0.0, VIDA_MAXIMA_JABALI, VIDA_MAXIMA_JABALI, "patrullando")
	_registrar_entidad("limo", Vector3(-10.0, _altura_terreno(-10.0, -8.0), -8.0), "Limo del Bosque", 0.0, VIDA_MAXIMA_LIMO, VIDA_MAXIMA_LIMO, "patrullando")
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


func _registrar_entidad(
	tipo: String,
	posicion: Vector3,
	nombre: String = "",
	yaw: float = 0.0,
	hp: int = 100,
	hp_max: int = 100,
	estado: String = "idle"
) -> int:
	var id := siguiente_id_entidad
	siguiente_id_entidad += 1

	var entidad := {
		"id": id,
		"type": tipo,
		"name": nombre,
		"x": posicion.x,
		"y": posicion.y,
		"z": posicion.z,
		"yaw": yaw,
		"hp": hp,
		"hp_max": hp_max,
		"estado": estado,
		"activo": true
	}

	entidades[id] = entidad
	datos_spawn_original[id] = {
		"x": posicion.x,
		"y": posicion.y,
		"z": posicion.z,
		"yaw": yaw,
		"hp_max": hp_max,
		"estado": estado
	}

	if not jugadores.is_empty():
		_difundir({
			"type": "entity_spawned",
			"entity": entidad
		})

	print("Entidad registrada: ", id, " | ", tipo, " | ", nombre)
	return id


func _obtener_entidad(id: int) -> Dictionary:
	if entidades.has(id):
		return entidades[id].duplicate(true)
	return {}


func _actualizar_entidad(id: int, cambios: Dictionary) -> void:
	if not entidades.has(id):
		return

	var entidad: Dictionary = entidades[id]
	for clave in cambios.keys():
		entidad[clave] = cambios[clave]

	var paquete := {
		"type": "entity_updated",
		"id": id
	}
	for clave in cambios.keys():
		paquete[clave] = cambios[clave]

	if not jugadores.is_empty():
		_difundir(paquete)


func _eliminar_entidad(id: int) -> void:
	if not entidades.has(id):
		return

	entidades.erase(id)
	temporizadores_respawn.erase(id)
	datos_spawn_original.erase(id)

	_difundir({
		"type": "entity_removed",
		"id": id
	})

	print("Entidad eliminada: ", id)


func _actualizar_ia_entidades(delta: float) -> void:
	if jugadores.is_empty():
		return

	tiempo_ia_entidades += delta
	if tiempo_ia_entidades >= 3.0:
		tiempo_ia_entidades = 0.0
		var lobo: Dictionary = entidades.get(3, {})
		if not lobo.is_empty() and bool(lobo.get("activo", true)) and str(lobo.get("estado", "")) != "muerto":
			var waypoints_lobo := [
				Vector2(-3.0, 0.0),
				Vector2(-2.0, -1.5),
				Vector2(-3.0, -3.0),
				Vector2(-4.0, -1.5)
			]
			paso_patrulla_lobo = _mover_entidad_patrulla(3, waypoints_lobo, paso_patrulla_lobo)

	tiempo_ia_jabali += delta
	if tiempo_ia_jabali >= 4.0:
		tiempo_ia_jabali = 0.0
		var jabali: Dictionary = entidades.get(4, {})
		if not jabali.is_empty() and bool(jabali.get("activo", true)) and str(jabali.get("estado", "")) != "muerto":
			var waypoints_jabali := [
				Vector2(8.0, -8.0),
				Vector2(9.5, -8.0),
				Vector2(9.5, -10.0),
				Vector2(8.0, -10.0)
			]
			paso_patrulla_jabali = _mover_entidad_patrulla(4, waypoints_jabali, paso_patrulla_jabali)

	tiempo_ia_limo += delta
	if tiempo_ia_limo >= 4.5:
		tiempo_ia_limo = 0.0
		var limo: Dictionary = entidades.get(5, {})
		if not limo.is_empty() and bool(limo.get("activo", true)) and str(limo.get("estado", "")) != "muerto":
			var waypoints_limo := [
				Vector2(-10.0, -8.0),
				Vector2(-8.8, -8.0),
				Vector2(-8.8, -9.4),
				Vector2(-10.0, -9.4)
			]
			paso_patrulla_limo = _mover_entidad_patrulla(5, waypoints_limo, paso_patrulla_limo)


func _mover_entidad_patrulla(id: int, waypoints: Array, paso_actual: int) -> int:
	if not entidades.has(id) or waypoints.is_empty():
		return paso_actual
	var siguiente_paso := (paso_actual + 1) % waypoints.size()
	var objetivo: Vector2 = waypoints[siguiente_paso]
	var entidad: Dictionary = entidades[id]
	var posicion_actual := Vector2(float(entidad.get("x", 0.0)), float(entidad.get("z", 0.0)))
	var direccion := objetivo - posicion_actual
	_actualizar_entidad(id, {
		"x": objetivo.x,
		"y": _altura_terreno(objetivo.x, objetivo.y),
		"z": objetivo.y,
		"yaw": atan2(direccion.x, direccion.y),
		"estado": "patrullando"
	})
	return siguiente_paso

func _actualizar_respawn(delta: float) -> void:
	for id_var in temporizadores_respawn.keys():
		var id := int(id_var)
		temporizadores_respawn[id] -= delta
		if temporizadores_respawn[id] <= 0.0:
			temporizadores_respawn.erase(id)
			if entidades.has(id) and datos_spawn_original.has(id):
				var orig: Dictionary = datos_spawn_original[id]
				_actualizar_entidad(id, {
					"hp": orig["hp_max"],
					"estado": orig["estado"],
					"activo": true,
					"x": orig["x"],
					"y": orig["y"],
					"z": orig["z"],
					"yaw": orig["yaw"]
				})
				if id == 3:
					paso_patrulla_lobo = 0
					tiempo_ia_entidades = 0.0
				elif id == 4:
					paso_patrulla_jabali = 0
					tiempo_ia_jabali = 0.0
					tiempo_ataque_jabali = 0.0
				elif id == 5:
					paso_patrulla_limo = 0
					tiempo_ia_limo = 0.0
					tiempo_ataque_limo = 0.0
				print("Entidad reaparecida (respawn autoritativo): ", id, " | HP: ", orig["hp_max"])


func _process(delta: float) -> void:
	servidor.poll()
	_actualizar_ia_entidades(delta)
	_actualizar_respawn(delta)
	_actualizar_ataques_enemigos(delta)
	_actualizar_respawn_jugadores(delta)

	if modo_individual:
		tiempo_guardado_local += delta
		if tiempo_guardado_local >= INTERVALO_GUARDADO_LOCAL:
			tiempo_guardado_local = 0.0
			_guardar_partidas_locales()

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

		var tipo_mensaje: String = datos.get("type", "")
		if tipo_mensaje == "move":
			_procesar_movimiento(id, datos)
		elif tipo_mensaje == "attack":
			_procesar_ataque(id, datos)
		elif tipo_mensaje == "interact":
			_procesar_interaccion(id, datos)
		elif tipo_mensaje == "use_item":
			_procesar_uso_objeto(id, datos)
		elif tipo_mensaje == "equip_item": 			_procesar_equipar_objeto(id, datos)
		elif tipo_mensaje == "discard_item":
			_procesar_descartar_objeto(id, datos)
		elif tipo_mensaje == "buy_item":
			_procesar_compra_tienda(id, datos)
		elif tipo_mensaje == "assign_attribute":
			_procesar_asignar_atributo(id, datos)


func _procesar_ataque(id: int, datos: Dictionary) -> void:
	if not jugadores.has(id):
		return

	var salud_atacante := _datos_salud_jugador(id)
	if bool(salud_atacante.get("muerto", false)):
		var res_muerto := {
			"type": "attack_result",
			"success": false,
			"reason": "player_dead"
		}
		emit_signal("ataque_procesado", id, res_muerto)
		_enviar(id, res_muerto)
		return

	var target_id := int(datos.get("target_id", 0))
	if target_id <= 0 or not entidades.has(target_id):
		var res_invalid := {
			"type": "attack_result",
			"success": false,
			"reason": "invalid_target",
			"target_id": target_id
		}
		emit_signal("ataque_procesado", id, res_invalid)
		_enviar(id, res_invalid)
		return

	var entidad: Dictionary = entidades[target_id]
	if not bool(entidad.get("activo", true)) or String(entidad.get("estado", "")) == "muerto":
		var res_dead := {
			"type": "attack_result",
			"success": false,
			"reason": "target_dead",
			"target_id": target_id
		}
		emit_signal("ataque_procesado", id, res_dead)
		_enviar(id, res_dead)
		return

	var skill_id := str(datos.get("skill_id", "normal"))
	if not ["normal", "golpe_pesado"].has(skill_id):
		var res_skill := {
			"type": "attack_result",
			"success": false,
			"reason": "invalid_skill",
			"target_id": target_id
		}
		emit_signal("ataque_procesado", id, res_skill)
		_enviar(id, res_skill)
		return

	var tiempo_actual := Time.get_ticks_msec() / 1000.0
	var ultimo_ataque: float = float(tiempos_ultimo_ataque.get(id, -100.0))
	if (tiempo_actual - ultimo_ataque) < TIEMPO_RECARGA_ATAQUE:
		var res_cd := {
			"type": "attack_result",
			"success": false,
			"reason": "on_cooldown",
			"target_id": target_id,
			"cooldown_restante": TIEMPO_RECARGA_ATAQUE - (tiempo_actual - ultimo_ataque)
		}
		emit_signal("ataque_procesado", id, res_cd)
		_enviar(id, res_cd)
		return
	if skill_id == "golpe_pesado":
		var ultimo_golpe_pesado := float(tiempos_ultimo_golpe_pesado.get(id, -100.0))
		var restante := TIEMPO_RECARGA_GOLPE_PESADO - (tiempo_actual - ultimo_golpe_pesado)
		if restante > 0.0:
			var res_skill_cd := {
				"type": "attack_result",
				"success": false,
				"reason": "skill_on_cooldown",
				"target_id": target_id,
				"skill_id": skill_id,
				"cooldown_restante": restante
			}
			emit_signal("ataque_procesado", id, res_skill_cd)
			_enviar(id, res_skill_cd)
			return

	var jug: Dictionary = jugadores[id]
	var pos_jugador := Vector3(float(jug["x"]), float(jug["y"]), float(jug["z"]))
	var pos_entidad := Vector3(float(entidad["x"]), float(entidad["y"]), float(entidad["z"]))
	var distancia := pos_jugador.distance_to(pos_entidad)

	if distancia > RANGO_ATAQUE_MELEE:
		var res_range := {
			"type": "attack_result",
			"success": false,
			"reason": "out_of_range",
			"target_id": target_id,
			"distancia": distancia,
			"rango_max": RANGO_ATAQUE_MELEE
		}
		emit_signal("ataque_procesado", id, res_range)
		_enviar(id, res_range)
		return

	tiempos_ultimo_ataque[id] = tiempo_actual
	if skill_id == "golpe_pesado":
		tiempos_ultimo_golpe_pesado[id] = tiempo_actual

	var nivel_jugador := int(_datos_progresion(id).get("level", 1))
	var danio_equipo := _bono_danio_equipado(id)
	var fuerza := int(_datos_progresion(id).get("strength", 0))
	var danio_base := DANIO_BASE_MELEE + maxi(0, nivel_jugador - 1) * DANIO_BONUS_POR_NIVEL + fuerza * DANIO_POR_FUERZA + danio_equipo
	var danio_melee := danio_base * MULTIPLICADOR_GOLPE_PESADO if skill_id == "golpe_pesado" else danio_base
	var hp_actual := int(entidad.get("hp", 100))
	var nueva_hp := maxi(0, hp_actual - danio_melee)
	var nuevo_estado := String(entidad.get("estado", "activo"))
	var nuevo_activo := true
	var xp_otorgada := 0
	var nivel_final := nivel_jugador

	if nueva_hp <= 0:
		nuevo_estado = "muerto"
		nuevo_activo = false
		temporizadores_respawn[target_id] = TIEMPO_RESPAWN

	_actualizar_entidad(target_id, {
		"hp": nueva_hp,
		"estado": nuevo_estado,
		"activo": nuevo_activo
	})

	if nueva_hp <= 0 and String(entidad.get("type", "")) == "lobo":
		_agregar_objeto_inventario(id, "colmillo_lobo", 1)
		_agregar_objeto_inventario(id, "piel_lobo", 1)
		_agregar_experiencia(id, XP_POR_LOBO)
		xp_otorgada = XP_POR_LOBO + _registrar_baja_mision_lobo(id)
		nivel_final = int(_datos_progresion(id).get("level", nivel_jugador))
	elif nueva_hp <= 0 and str(entidad.get("type", "")) == "jabali":
		_agregar_objeto_inventario(id, "colmillo_jabali", 1)
		_agregar_objeto_inventario(id, "carne_jabali", 1)
		_agregar_experiencia(id, XP_POR_JABALI)
		xp_otorgada = XP_POR_JABALI
		nivel_final = int(_datos_progresion(id).get("level", nivel_jugador))
		var mision_jabali: Dictionary = _datos_mision(id)
		if str(mision_jabali.get("id", "")) == "caza_jabalies" and str(mision_jabali.get("estado", "")) == "activa":
			mision_jabali["jabalies"] = mini(JABALIES_REQUERIDOS_MISION, int(mision_jabali.get("jabalies", 0)) + 1)
			misiones_jugadores[id] = mision_jabali
			if int(mision_jabali["jabalies"]) >= JABALIES_REQUERIDOS_MISION:
				mision_jabali["estado"] = "completada"
				_agregar_experiencia(id, XP_RECOMPENSA_CAZA_JABALI)
				_agregar_oro(id, ORO_RECOMPENSA_CAZA_JABALIES)
				xp_otorgada += XP_RECOMPENSA_CAZA_JABALI
				mision_jabali["jabalies"] = JABALIES_REQUERIDOS_MISION
				_notificar_mision(id, "¡Caza de jabalíes completada! Recompensa: %d XP." % XP_RECOMPENSA_CAZA_JABALI)
			else:
				_notificar_mision(id, "Jabalíes derrotados: %d/%d." % [mision_jabali["jabalies"], JABALIES_REQUERIDOS_MISION])
			_guardar_partida_local(id)
	elif nueva_hp <= 0 and str(entidad.get("type", "")) == "limo":
		_agregar_objeto_inventario(id, "gelatina_limo", 1)
		_agregar_experiencia(id, XP_POR_LIMO)
		xp_otorgada = XP_POR_LIMO
		nivel_final = int(_datos_progresion(id).get("level", nivel_jugador))

	var res_success := {
		"type": "attack_result",
		"success": true,
		"target_id": target_id,
		"skill_id": skill_id,
		"damage": danio_melee,
		"equipment_damage_bonus": danio_equipo,
		"target_hp": nueva_hp,
		"target_state": nuevo_estado,
		"xp_gained": xp_otorgada,
		"level_up": nivel_final > nivel_jugador,
		"new_level": nivel_final
	}
	_difundir({
		"type": "player_attack",
		"id": id,
		"skill_id": skill_id
	}, id)
	emit_signal("ataque_procesado", id, res_success)
	_enviar(id, res_success)


func _datos_equipamiento(id: int) -> Dictionary:
	var equipo: Dictionary = equipamiento_jugadores.get(id, {"arma": ""})
	return equipo.duplicate(true)


func _bono_danio_equipado(id: int) -> int:
	var equipo := _datos_equipamiento(id)
	var id_arma := str(equipo.get("arma", ""))
	var definicion := CatalogoObjetos.obtener(id_arma)
	return maxi(0, int(definicion.get("bono_danio", 0)))


func _procesar_equipar_objeto(id: int, datos: Dictionary) -> Dictionary:
	var id_objeto := str(datos.get("item_id", ""))
	var resultado := {
		"type": "equipment_result",
		"success": false,
		"item_id": id_objeto,
		"reason": "not_equipment"
	}
	if not jugadores.has(id):
		return resultado
	if bool(_datos_salud_jugador(id).get("muerto", false)):
		resultado["reason"] = "player_dead"
		_enviar(id, resultado)
		return resultado

	var equipo := _datos_equipamiento(id)
	if id_objeto.is_empty():
		equipo["arma"] = ""
		equipamiento_jugadores[id] = equipo
		_guardar_partida_local(id)
		resultado["success"] = true
		resultado["reason"] = ""
		_enviar(id, {"type": "equipment_updated", "equipment": _datos_equipamiento(id)})
		_enviar(id, resultado)
		return resultado

	var definicion := CatalogoObjetos.obtener(id_objeto)
	if str(definicion.get("tipo", "")) != "equipo":
		_enviar(id, resultado)
		return resultado
	if int(inventarios.get(id, {}).get(id_objeto, 0)) <= 0:
		resultado["reason"] = "not_owned"
		_enviar(id, resultado)
		return resultado

	var ranura := str(definicion.get("ranura", ""))
	if ranura.is_empty():
		resultado["reason"] = "invalid_equipment"
		_enviar(id, resultado)
		return resultado

	equipo[ranura] = id_objeto
	equipamiento_jugadores[id] = equipo
	_guardar_partida_local(id)
	resultado["success"] = true
	resultado["reason"] = ""
	resultado["slot"] = ranura
	_enviar(id, {"type": "equipment_updated", "equipment": _datos_equipamiento(id)})
	_enviar(id, resultado)
	return resultado


func _procesar_descartar_objeto(id: int, datos: Dictionary) -> Dictionary:
	var id_objeto := str(datos.get("item_id", ""))
	var resultado := {
		"type": "discard_item_result",
		"success": false,
		"item_id": id_objeto,
		"reason": "invalid_item"
	}
	if not jugadores.has(id):
		return resultado

	if bool(_datos_salud_jugador(id).get("muerto", false)):
		resultado["reason"] = "player_dead"
		_enviar(id, resultado)
		return resultado

	if CatalogoObjetos.obtener(id_objeto).is_empty():
		_enviar(id, resultado)
		return resultado

	var inventario: Dictionary = inventarios.get(id, {})
	var cantidad := int(inventario.get(id_objeto, 0))
	if cantidad <= 0:
		resultado["reason"] = "not_owned"
		_enviar(id, resultado)
		return resultado

	if cantidad == 1:
		inventario.erase(id_objeto)
	else:
		inventario[id_objeto] = cantidad - 1
	inventarios[id] = inventario

	var equipo_actualizado := false
	var definicion := CatalogoObjetos.obtener(id_objeto)
	var ranura := str(definicion.get("ranura", ""))
	var equipo := _datos_equipamiento(id)
	if cantidad == 1 and not ranura.is_empty() and str(equipo.get(ranura, "")) == id_objeto:
		equipo[ranura] = ""
		equipamiento_jugadores[id] = equipo
		equipo_actualizado = true

	var mision: Dictionary = _datos_mision(id)
	if str(mision.get("estado", "")) == "activa":
		var progreso_actualizado := false
		var campo_progreso := ""
		var objetivo_mision := 0
		var cantidad_restante := cantidad - 1
		match id_objeto:
			"piel_lobo":
				if str(mision.get("id", "")) == "entrega_pieles":
					mision["pieles"] = mini(cantidad_restante, PIEL_LOBO_REQUERIDAS_ENTREGA)
					progreso_actualizado = true
					campo_progreso = "pieles"
					objetivo_mision = PIEL_LOBO_REQUERIDAS_ENTREGA
			"carne_jabali":
				if str(mision.get("id", "")) == "entrega_carne_jabali":
					mision["carne"] = mini(cantidad_restante, CARNE_JABALI_REQUERIDA_MISION)
					progreso_actualizado = true
					campo_progreso = "carne"
					objetivo_mision = CARNE_JABALI_REQUERIDA_MISION
			"gelatina_limo":
				if str(mision.get("id", "")) == "entrega_gelatina_limo":
					mision["gelatina"] = mini(cantidad_restante, GELATINA_LIMO_REQUERIDA_MISION)
					progreso_actualizado = true
					campo_progreso = "gelatina"
					objetivo_mision = GELATINA_LIMO_REQUERIDA_MISION
		if progreso_actualizado:
			misiones_jugadores[id] = mision
			_notificar_mision(id, "Progreso actualizado: %d/%d objetos disponibles." % [int(mision.get(campo_progreso, 0)), objetivo_mision])

	_guardar_partida_local(id)
	_enviar(id, {"type": "inventory_updated", "items": _datos_inventario(id)})
	if equipo_actualizado:
		_enviar(id, {"type": "equipment_updated", "equipment": _datos_equipamiento(id)})
	resultado["success"] = true
	resultado["reason"] = ""
	_enviar(id, resultado)
	return resultado


func _procesar_uso_objeto(id: int, datos: Dictionary) -> Dictionary:
	var id_objeto := str(datos.get("item_id", ""))
	var resultado := {
		"type": "item_use_result",
		"success": false,
		"item_id": id_objeto,
		"reason": "invalid_item"
	}
	if not jugadores.has(id):
		return resultado

	var salud := _datos_salud_jugador(id)
	if bool(salud.get("muerto", false)):
		resultado["reason"] = "player_dead"
		_enviar(id, resultado)
		return resultado

	var definicion := CatalogoObjetos.obtener(id_objeto)
	if str(definicion.get("tipo", "")) != "consumible":
		resultado["reason"] = "not_usable"
		_enviar(id, resultado)
		return resultado

	var inventario: Dictionary = inventarios.get(id, {})
	var cantidad := int(inventario.get(id_objeto, 0))
	if cantidad <= 0:
		resultado["reason"] = "not_owned"
		_enviar(id, resultado)
		return resultado

	var hp_actual := int(salud.get("hp", VIDA_MAXIMA_JUGADOR))
	var hp_max := int(salud.get("hp_max", VIDA_MAXIMA_JUGADOR))
	if hp_actual >= hp_max:
		resultado["reason"] = "health_full"
		_enviar(id, resultado)
		return resultado

	var curacion := mini(int(definicion.get("curacion", 0)), hp_max - hp_actual)
	if curacion <= 0:
		resultado["reason"] = "no_effect"
		_enviar(id, resultado)
		return resultado

	salud_jugadores[id] = {
		"hp": hp_actual + curacion,
		"hp_max": hp_max,
		"muerto": false
	}
	if cantidad == 1:
		inventario.erase(id_objeto)
	else:
		inventario[id_objeto] = cantidad - 1
	inventarios[id] = inventario
	_guardar_partida_local(id)

	var evento_salud := _datos_salud_jugador(id)
	evento_salud["type"] = "player_health_updated"
	evento_salud["healing"] = curacion
	_enviar(id, evento_salud)
	_enviar(id, {"type": "inventory_updated", "items": _datos_inventario(id)})
	resultado["success"] = true
	resultado["healed"] = curacion
	_enviar(id, resultado)
	return resultado


func _mision_inicial() -> Dictionary:
	return {
		"id": "caza_lobos",
		"estado": "disponible",
		"lobos": 0,
		"objetivo_lobos": LOBOS_REQUERIDOS_MISION
	}


func _mision_entrega_pieles() -> Dictionary:
	return {
		"id": "entrega_pieles",
		"estado": "disponible",
		"pieles": 0,
		"objetivo_pieles": PIEL_LOBO_REQUERIDAS_ENTREGA
	}


func _mision_entrega_carne() -> Dictionary:
	return {
		"id": "entrega_carne_jabali",
		"estado": "disponible",
		"carne": 0,
		"objetivo_carne": CARNE_JABALI_REQUERIDA_MISION
	}


func _mision_caza_jabalies() -> Dictionary:
	return {"id": "caza_jabalies", "estado": "disponible", "jabalies": 0, "objetivo_jabalies": JABALIES_REQUERIDOS_MISION, "recompensa_reclamada": false}


func _mision_entrega_gelatina() -> Dictionary:
	return {"id": "entrega_gelatina_limo", "estado": "disponible", "gelatina": 0, "objetivo_gelatina": GELATINA_LIMO_REQUERIDA_MISION}


func _datos_mision(id: int) -> Dictionary:
	var mision: Dictionary = misiones_jugadores.get(id, _mision_inicial())
	return mision.duplicate(true)


func _notificar_mision(id: int, mensaje: String) -> void:
	_enviar(id, {
		"type": "quest_updated",
		"id": id,
		"quest": _datos_mision(id),
		"message": mensaje
	})


func _procesar_interaccion(id: int, datos: Dictionary) -> void:
	if not jugadores.has(id):
		return
	if bool(_datos_salud_jugador(id).get("muerto", false)):
		_notificar_mision(id, "No puedes hablar mientras estás derrotado.")
		return

	var objetivo_id := int(datos.get("target_id", 0))
	if not entidades.has(objetivo_id):
		_notificar_mision(id, "No hay nadie con quien hablar.")
		return

	var entidad: Dictionary = entidades[objetivo_id]
	if str(entidad.get("type", "")) != "npc":
		_notificar_mision(id, "Selecciona al Habitante para hablar.")
		return

	var jugador: Dictionary = jugadores[id]
	var distancia := Vector2(
		float(jugador.get("x", 0.0)) - float(entidad.get("x", 0.0)),
		float(jugador.get("z", 0.0)) - float(entidad.get("z", 0.0))
	).length()
	if distancia > RANGO_INTERACCION:
		_notificar_mision(id, "Acércate al Habitante para hablar.")
		return

	var mision: Dictionary = _datos_mision(id)
	var id_mision := str(mision.get("id", "caza_lobos"))
	var estado := str(mision.get("estado", "disponible"))
	if id_mision == "caza_lobos":
		if estado == "disponible":
			mision["estado"] = "activa"
			misiones_jugadores[id] = mision
			_guardar_partida_local(id)
			_notificar_mision(id, "Misión aceptada: derrota 3 lobos del bosque.")
		elif estado == "activa":
			var lobos := int(mision.get("lobos", 0))
			_notificar_mision(id, "El bosque sigue amenazado: lobos %d/%d." % [lobos, LOBOS_REQUERIDOS_MISION])
		else:
			var entrega := _mision_entrega_pieles()
			entrega["estado"] = "activa"
			entrega["pieles"] = mini(
				int(inventarios.get(id, {}).get("piel_lobo", 0)),
				PIEL_LOBO_REQUERIDAS_ENTREGA
			)
			misiones_jugadores[id] = entrega
			_guardar_partida_local(id)
			_notificar_mision(id, "Nueva misión: entrega 3 pieles de lobo al Habitante.")
		return

	if id_mision == "entrega_pieles":
		if estado == "activa":
			_entregar_pieles_lobo(id, mision)
		else:
			var entrega_carne := _mision_entrega_carne()
			entrega_carne["estado"] = "activa"
			entrega_carne["carne"] = mini(
				int(inventarios.get(id, {}).get("carne_jabali", 0)),
				CARNE_JABALI_REQUERIDA_MISION
			)
			misiones_jugadores[id] = entrega_carne
			_guardar_partida_local(id)
			_notificar_mision(id, "Nueva misión: reúne y entrega 3 carnes de jabalí al Habitante.")
		return

	if id_mision == "entrega_carne_jabali":
		if estado == "activa":
			_entregar_carne_jabali(id, mision)
		else:
			var caza := _mision_caza_jabalies()
			caza["estado"] = "activa"
			misiones_jugadores[id] = caza
			_guardar_partida_local(id)
			_notificar_mision(id, "Nueva misión: derrota 3 jabalíes del bosque.")
		return
	if id_mision == "caza_jabalies":
		if estado == "completada" and not bool(mision.get("recompensa_reclamada", false)):
			var inventario_recompensa: Dictionary = inventarios.get(id, {})
			var pociones_actuales := int(inventario_recompensa.get("pocion_curativa", 0))
			var max_pociones := int(CatalogoObjetos.obtener("pocion_curativa").get("max_pila", 1))
			if pociones_actuales + 2 > max_pociones or not _inventario_tiene_espacio(inventario_recompensa, "pocion_curativa"):
				_notificar_mision(id, "Libera espacio o consume pociones antes de reclamar la recompensa.")
				return
			mision["recompensa_reclamada"] = true
			misiones_jugadores[id] = mision
			_agregar_objeto_inventario(id, "pocion_curativa", 2)
			_guardar_partida_local(id)
			_notificar_mision(id, "Recompensa recibida: 2 pociones curativas.")
		elif estado == "completada" and bool(mision.get("recompensa_reclamada", false)):
			var entrega_gelatina := _mision_entrega_gelatina()
			entrega_gelatina["estado"] = "activa"
			entrega_gelatina["gelatina"] = mini(
				int(inventarios.get(id, {}).get("gelatina_limo", 0)),
				GELATINA_LIMO_REQUERIDA_MISION
			)
			misiones_jugadores[id] = entrega_gelatina
			_guardar_partida_local(id)
			_notificar_mision(id, "Nueva misión: reúne y entrega 3 gelatinas de limo al Habitante.")
		else:
			_notificar_mision(id, "Jabalíes derrotados: %d/%d." % [int(mision.get("jabalies", 0)), JABALIES_REQUERIDOS_MISION])
		return
	if id_mision == "entrega_gelatina_limo":
		if estado == "activa":
			_entregar_gelatina_limo(id, mision)
		else:
			_notificar_mision(id, "¡El bosque está en calma gracias a ti! Has completado todas las tareas.")
		return

	_notificar_mision(id, "No hay una misión disponible para esta conversación.")


func _esta_cerca_de_npc(id: int) -> bool:
	if not jugadores.has(id):
		return false
	var jugador: Dictionary = jugadores[id]
	for entidad in entidades.values():
		if str(entidad.get("type", "")) != "npc":
			continue
		var distancia := Vector2(
			float(jugador.get("x", 0.0)) - float(entidad.get("x", 0.0)),
			float(jugador.get("z", 0.0)) - float(entidad.get("z", 0.0))
		).length()
		if distancia <= RANGO_INTERACCION:
			return true
	return false


func _procesar_compra_tienda(id: int, datos: Dictionary) -> Dictionary:
	var id_objeto := str(datos.get("item_id", ""))
	var definicion := CatalogoObjetos.obtener(id_objeto)
	var precio := int(definicion.get("precio_compra", 0))
	var resultado := {
		"type": "shop_result",
		"success": false,
		"item_id": id_objeto,
		"price": precio,
		"gold": _datos_oro(id),
		"reason": "invalid_item"
	}
	if not jugadores.has(id):
		return resultado

	if bool(_datos_salud_jugador(id).get("muerto", false)):
		resultado["reason"] = "player_dead"
	elif id_objeto != "pocion_curativa" or precio <= 0:
		resultado["reason"] = "not_sold"
	elif not _esta_cerca_de_npc(id):
		resultado["reason"] = "shop_out_of_range"
	else:
		var oro_actual := _datos_oro(id)
		var inventario: Dictionary = inventarios.get(id, {})
		var cantidad_actual := int(inventario.get(id_objeto, 0))
		var max_pila := int(definicion.get("max_pila", 1))
		if oro_actual < precio:
			resultado["reason"] = "insufficient_gold"
		elif cantidad_actual >= max_pila:
			resultado["reason"] = "stack_full"
		elif not _inventario_tiene_espacio(inventario, id_objeto):
			resultado["reason"] = "slots_full"
		else:
			var oro_restante := oro_actual - precio
			oro_jugadores[id] = oro_restante
			_enviar(id, {"type": "gold_updated", "gold": oro_restante})
			_agregar_objeto_inventario(id, id_objeto, 1)
			resultado["success"] = true
			resultado["reason"] = ""
			resultado["gold"] = oro_restante
			_guardar_partida_local(id)

	_enviar(id, resultado)
	return resultado


func _entregar_pieles_lobo(id: int, mision: Dictionary) -> void:
	var objetivo := PIEL_LOBO_REQUERIDAS_ENTREGA
	var inventario: Dictionary = inventarios.get(id, {})
	var disponibles := int(inventario.get("piel_lobo", 0))
	if disponibles < objetivo:
		mision["pieles"] = disponibles
		misiones_jugadores[id] = mision
		_guardar_partida_local(id)
		_notificar_mision(id, "Necesitas %d pieles de lobo. Tienes %d/%d." % [objetivo, disponibles, objetivo])
		return

	var restantes := disponibles - objetivo
	if restantes > 0:
		inventario["piel_lobo"] = restantes
	else:
		inventario.erase("piel_lobo")
	inventarios[id] = inventario
	mision["pieles"] = objetivo
	mision["estado"] = "completada"
	misiones_jugadores[id] = mision
	_enviar(id, {"type": "inventory_updated", "items": _datos_inventario(id)})
	_agregar_experiencia(id, XP_RECOMPENSA_ENTREGA)
	_agregar_oro(id, ORO_RECOMPENSA_ENTREGA_PIELES)
	_notificar_mision(id, "¡Entrega completada! Recompensa: %d XP." % XP_RECOMPENSA_ENTREGA)
	_guardar_partida_local(id)


func _entregar_carne_jabali(id: int, mision: Dictionary) -> void:
	var objetivo := CARNE_JABALI_REQUERIDA_MISION
	var inventario: Dictionary = inventarios.get(id, {})
	var disponibles := int(inventario.get("carne_jabali", 0))
	if disponibles < objetivo:
		mision["carne"] = disponibles
		misiones_jugadores[id] = mision
		_guardar_partida_local(id)
		_notificar_mision(id, "Necesitas %d carnes de jabalí. Tienes %d/%d." % [objetivo, disponibles, objetivo])
		return

	var restantes := disponibles - objetivo
	if restantes > 0:
		inventario["carne_jabali"] = restantes
	else:
		inventario.erase("carne_jabali")
	inventarios[id] = inventario
	mision["carne"] = objetivo
	mision["estado"] = "completada"
	misiones_jugadores[id] = mision
	_enviar(id, {"type": "inventory_updated", "items": _datos_inventario(id)})
	_agregar_experiencia(id, XP_RECOMPENSA_ENTREGA_CARNE)
	_agregar_oro(id, ORO_RECOMPENSA_ENTREGA_CARNE)
	_notificar_mision(id, "¡Entrega completada! Recompensa: %d XP." % XP_RECOMPENSA_ENTREGA_CARNE)
	_guardar_partida_local(id)


func _entregar_gelatina_limo(id: int, mision: Dictionary) -> void:
	var objetivo := GELATINA_LIMO_REQUERIDA_MISION
	var inventario: Dictionary = inventarios.get(id, {})
	var disponibles := int(inventario.get("gelatina_limo", 0))
	if disponibles < objetivo:
		mision["gelatina"] = disponibles
		misiones_jugadores[id] = mision
		_guardar_partida_local(id)
		_notificar_mision(id, "Necesitas %d gelatinas de limo. Tienes %d/%d." % [objetivo, disponibles, objetivo])
		return

	var restantes := disponibles - objetivo
	if restantes > 0:
		inventario["gelatina_limo"] = restantes
	else:
		inventario.erase("gelatina_limo")
	inventarios[id] = inventario
	mision["gelatina"] = objetivo
	mision["estado"] = "completada"
	misiones_jugadores[id] = mision
	_enviar(id, {"type": "inventory_updated", "items": _datos_inventario(id)})
	_agregar_experiencia(id, XP_RECOMPENSA_ENTREGA_GELATINA)
	_agregar_oro(id, ORO_RECOMPENSA_ENTREGA_GELATINA)
	_notificar_mision(id, "¡Gelatinas entregadas! Recompensa: %d XP." % XP_RECOMPENSA_ENTREGA_GELATINA)
	_guardar_partida_local(id)


func _registrar_baja_mision_lobo(id: int) -> int:
	if not misiones_jugadores.has(id):
		return 0

	var mision: Dictionary = _datos_mision(id)
	if str(mision.get("id", "")) != "caza_lobos" or str(mision.get("estado", "")) != "activa":
		return 0

	var lobos := int(mision.get("lobos", 0)) + 1
	var objetivo := int(mision.get("objetivo_lobos", LOBOS_REQUERIDOS_MISION))
	mision["lobos"] = mini(lobos, objetivo)
	var recompensa := 0
	var mensaje := "Progreso de misión: lobos %d/%d." % [mision["lobos"], objetivo]
	if lobos >= objetivo:
		mision["estado"] = "completada"
		recompensa = XP_RECOMPENSA_MISION
		mensaje = "¡Misión completada! Recompensa: %d XP." % recompensa

	misiones_jugadores[id] = mision
	if recompensa > 0:
		_agregar_experiencia(id, recompensa)
		_agregar_objeto_inventario(id, "pocion_curativa", 2)
		_agregar_objeto_inventario(id, "espada_del_habitante", 1)
		_agregar_oro(id, ORO_RECOMPENSA_CAZA_LOBOS)
	_notificar_mision(id, mensaje)
	_guardar_partida_local(id)
	return recompensa


func _datos_salud_jugador(id: int) -> Dictionary:
	var salud: Dictionary = salud_jugadores.get(id, {
		"hp": _vida_maxima_jugador(id),
		"hp_max": _vida_maxima_jugador(id),
		"muerto": false
	})
	salud = salud.duplicate(true)
	salud["id"] = id
	return salud


func _aplicar_danio_jugador(id: int, cantidad: int) -> Dictionary:
	if not jugadores.has(id) or not salud_jugadores.has(id) or cantidad <= 0:
		return {}

	var salud: Dictionary = _datos_salud_jugador(id)
	if bool(salud.get("muerto", false)):
		return salud

	var hp_actual := int(salud.get("hp", VIDA_MAXIMA_JUGADOR))
	var danio_aplicado := mini(hp_actual, cantidad)
	var hp_nueva := maxi(0, hp_actual - danio_aplicado)
	var muerto := hp_nueva <= 0

	salud_jugadores[id] = {
		"hp": hp_nueva,
		"hp_max": int(salud.get("hp_max", VIDA_MAXIMA_JUGADOR)),
		"muerto": muerto
	}

	if muerto:
		temporizadores_respawn_jugadores[id] = TIEMPO_RESPAWN_JUGADOR
		proteccion_respawn_jugadores.erase(id)

	var evento := _datos_salud_jugador(id)
	evento["type"] = "player_health_updated"
	evento["damage"] = danio_aplicado
	evento["respawn_seconds"] = TIEMPO_RESPAWN_JUGADOR if muerto else 0
	_difundir(evento)

	if muerto:
		print("Jugador derrotado: ", id, ". Reaparecerá en ", TIEMPO_RESPAWN_JUGADOR, " s.")
	_guardar_partida_local(id)
	return evento


func _actualizar_ataques_enemigos(delta: float) -> void:
	tiempo_ataque_lobo = maxf(0.0, tiempo_ataque_lobo - delta)
	tiempo_ataque_jabali = maxf(0.0, tiempo_ataque_jabali - delta)
	tiempo_ataque_limo = maxf(0.0, tiempo_ataque_limo - delta)

	for id_var in proteccion_respawn_jugadores.keys():
		var id_protegido := int(id_var)
		proteccion_respawn_jugadores[id_protegido] = maxf(
			0.0,
			float(proteccion_respawn_jugadores[id_protegido]) - delta
		)
		if proteccion_respawn_jugadores[id_protegido] <= 0.0:
			proteccion_respawn_jugadores.erase(id_protegido)

	tiempo_ataque_lobo = _procesar_ataque_enemigo(
		3, DANIO_LOBO, RANGO_ATAQUE_LOBO, TIEMPO_RECARGA_LOBO, tiempo_ataque_lobo
	)
	tiempo_ataque_jabali = _procesar_ataque_enemigo(
		4, DANIO_JABALI, RANGO_ATAQUE_JABALI, TIEMPO_RECARGA_JABALI, tiempo_ataque_jabali
	)
	tiempo_ataque_limo = _procesar_ataque_enemigo(
		5, DANIO_LIMO, RANGO_ATAQUE_LIMO, TIEMPO_RECARGA_LIMO, tiempo_ataque_limo
	)


func _procesar_ataque_enemigo(
	id_entidad: int,
	danio: int,
	rango: float,
	recarga: float,
	recarga_restante: float
) -> float:
	if recarga_restante > 0.0 or not entidades.has(id_entidad):
		return recarga_restante

	var enemigo: Dictionary = entidades[id_entidad]
	if not bool(enemigo.get("activo", true)) or str(enemigo.get("estado", "")) == "muerto":
		return 0.0

	var objetivo_id := -1
	var distancia_menor := rango
	for id_var in jugadores.keys():
		var id := int(id_var)
		if bool(_datos_salud_jugador(id).get("muerto", false)):
			continue
		if float(proteccion_respawn_jugadores.get(id, 0.0)) > 0.0:
			continue
		var jugador: Dictionary = jugadores[id]
		var distancia := Vector2(
			float(jugador.get("x", 0.0)) - float(enemigo.get("x", 0.0)),
			float(jugador.get("z", 0.0)) - float(enemigo.get("z", 0.0))
		).length()
		if distancia < distancia_menor:
			distancia_menor = distancia
			objetivo_id = id

	if objetivo_id < 0:
		return 0.0
	_aplicar_danio_jugador(objetivo_id, danio)
	return recarga


func _actualizar_respawn_jugadores(delta: float) -> void:
	for id_var in temporizadores_respawn_jugadores.keys():
		var id := int(id_var)
		if not jugadores.has(id):
			temporizadores_respawn_jugadores.erase(id)
			continue

		temporizadores_respawn_jugadores[id] -= delta
		if temporizadores_respawn_jugadores[id] > 0.0:
			continue

		temporizadores_respawn_jugadores.erase(id)
		var posicion: Vector3 = datos_spawn_jugadores.get(id, Vector3.ZERO)
		var estado: Dictionary = jugadores[id]
		estado["x"] = posicion.x
		estado["y"] = posicion.y
		estado["z"] = posicion.z
		estado["yaw"] = 0.0
		estado["sprint"] = false
		estado["en_el_aire"] = false
		estado["ultimo_movimiento_ms"] = Time.get_ticks_msec()
		estado["presupuesto_movimiento"] = PRESUPUESTO_MOVIMIENTO_INICIAL
		estado["altura_relativa"] = posicion.y - (
			_altura_terreno(posicion.x, posicion.z) + ALTURA_BASE_JUGADOR
		)
		jugadores[id] = estado

		var hp_maximo := _vida_maxima_jugador(id)
		salud_jugadores[id] = {
			"hp": hp_maximo,
			"hp_max": hp_maximo,
			"muerto": false
		}
		proteccion_respawn_jugadores[id] = PROTECCION_REAPARICION

		var evento := _datos_salud_jugador(id)
		evento["type"] = "player_respawned"
		evento["x"] = posicion.x
		evento["y"] = posicion.y
		evento["z"] = posicion.z
		evento["yaw"] = 0.0
		_difundir(evento)
		_guardar_partida_local(id)
		print("Jugador reaparecido: ", id, " | HP: ", hp_maximo)


func _datos_progresion(id: int) -> Dictionary:
	var progreso: Dictionary = progresion_jugadores.get(id, {"level": 1, "xp": 0, "xp_to_next": XP_PARA_SUBIR_NIVEL})
	return _normalizar_progresion(progreso)


func _vida_maxima_jugador(id: int) -> int:
	var vitalidad := int(_datos_progresion(id).get("vitality", 0))
	return VIDA_MAXIMA_JUGADOR + vitalidad * VIDA_POR_VITALIDAD


func _agregar_experiencia(id: int, cantidad: int) -> void:
	if not jugadores.has(id) or cantidad <= 0:
		return

	var progreso := _datos_progresion(id)
	var nivel := int(progreso.get("level", 1))
	var experiencia := int(progreso.get("xp", 0)) + cantidad
	while experiencia >= XP_PARA_SUBIR_NIVEL:
		experiencia -= XP_PARA_SUBIR_NIVEL
		nivel += 1

	progreso["level"] = nivel
	progreso["xp"] = experiencia
	progreso["xp_to_next"] = XP_PARA_SUBIR_NIVEL
	progresion_jugadores[id] = _normalizar_progresion(progreso)
	_enviar(id, {
		"type": "progression_updated",
		"progression": _datos_progresion(id)
	})
	_guardar_partida_local(id)
	print("Experiencia otorgada al jugador ", id, ": nivel ", nivel, ", XP ", experiencia, "/", XP_PARA_SUBIR_NIVEL)


func _procesar_asignar_atributo(id: int, datos: Dictionary) -> Dictionary:
	var atributo := str(datos.get("attribute", ""))
	var resultado := {
		"type": "attribute_result",
		"success": false,
		"attribute": atributo,
		"reason": "invalid_attribute"
	}
	if not jugadores.has(id):
		return resultado
	if bool(_datos_salud_jugador(id).get("muerto", false)):
		resultado["reason"] = "player_dead"
		_enviar(id, resultado)
		return resultado
	if not ["strength", "vitality"].has(atributo):
		_enviar(id, resultado)
		return resultado

	var progreso := _datos_progresion(id)
	var puntos := int(progreso.get("attribute_points", 0))
	if puntos <= 0:
		resultado["reason"] = "no_points"
		_enviar(id, resultado)
		return resultado

	var salud := _datos_salud_jugador(id)
	progreso[atributo] = int(progreso.get(atributo, 0)) + 1
	progreso["attribute_points"] = puntos - 1
	progresion_jugadores[id] = progreso

	if atributo == "vitality":
		var hp_maximo := _vida_maxima_jugador(id)
		var hp_actual := mini(hp_maximo, int(salud.get("hp", VIDA_MAXIMA_JUGADOR)) + VIDA_POR_VITALIDAD)
		salud_jugadores[id] = {"hp": hp_actual, "hp_max": hp_maximo, "muerto": false}
		var evento_salud := _datos_salud_jugador(id)
		evento_salud["type"] = "player_health_updated"
		_enviar(id, evento_salud)

	_enviar(id, {"type": "progression_updated", "progression": _datos_progresion(id)})
	resultado["success"] = true
	resultado["reason"] = ""
	resultado["progression"] = _datos_progresion(id)
	_enviar(id, resultado)
	_guardar_partida_local(id)
	return resultado

func _datos_inventario(id: int) -> Dictionary:
	var inventario: Dictionary = inventarios.get(id, {})
	return inventario.duplicate(true)


func _datos_oro(id: int) -> int:
	return _normalizar_oro(oro_jugadores.get(id, 0))


func _agregar_oro(id: int, cantidad: int) -> int:
	if not jugadores.has(id) or cantidad <= 0:
		return _datos_oro(id)
	var oro_nuevo := _normalizar_oro(_datos_oro(id) + cantidad)
	oro_jugadores[id] = oro_nuevo
	_enviar(id, {"type": "gold_updated", "gold": oro_nuevo})
	_guardar_partida_local(id)
	return oro_nuevo


func _inventario_tiene_espacio(inventario: Dictionary, id_objeto: String) -> bool:
	return inventario.has(id_objeto) or inventario.size() < CatalogoObjetos.CAPACIDAD_RANURAS


func _agregar_objeto_inventario(id: int, id_objeto: String, cantidad: int) -> void:
	if not jugadores.has(id) or cantidad <= 0:
		return

	var definicion := CatalogoObjetos.obtener(id_objeto)
	if definicion.is_empty():
		push_error("Objeto desconocido al otorgar botin: " + id_objeto)
		return

	var inventario: Dictionary = inventarios.get(id, {})
	if not _inventario_tiene_espacio(inventario, id_objeto):
		_enviar(id, {"type": "inventory_rejected", "item_id": id_objeto, "reason": "slots_full"})
		return
	var cantidad_actual := int(inventario.get(id_objeto, 0))
	var limite_pila := int(definicion.get("max_pila", 1))
	var cantidad_nueva := mini(limite_pila, cantidad_actual + cantidad)
	if cantidad_nueva <= cantidad_actual:
		_enviar(id, {"type": "inventory_rejected", "item_id": id_objeto, "reason": "stack_full"})
		return

	inventario[id_objeto] = cantidad_nueva
	inventarios[id] = inventario
	if id_objeto == "piel_lobo":
		var mision: Dictionary = _datos_mision(id)
		if str(mision.get("id", "")) == "entrega_pieles" and str(mision.get("estado", "")) == "activa":
			var agregadas := cantidad_nueva - cantidad_actual
			mision["pieles"] = mini(
				PIEL_LOBO_REQUERIDAS_ENTREGA,
				int(mision.get("pieles", 0)) + agregadas
			)
			misiones_jugadores[id] = mision
			_notificar_mision(id, "Pieles reunidas: %d/%d." % [mision["pieles"], PIEL_LOBO_REQUERIDAS_ENTREGA])
	elif id_objeto == "carne_jabali":
		var mision: Dictionary = _datos_mision(id)
		if str(mision.get("id", "")) == "entrega_carne_jabali" and str(mision.get("estado", "")) == "activa":
			var agregadas := cantidad_nueva - cantidad_actual
			mision["carne"] = mini(
				CARNE_JABALI_REQUERIDA_MISION,
				int(mision.get("carne", 0)) + agregadas
			)
			misiones_jugadores[id] = mision
			_notificar_mision(id, "Carne reunida: %d/%d." % [mision["carne"], CARNE_JABALI_REQUERIDA_MISION])
	elif id_objeto == "gelatina_limo":
		var mision: Dictionary = _datos_mision(id)
		if str(mision.get("id", "")) == "entrega_gelatina_limo" and str(mision.get("estado", "")) == "activa":
			var agregadas := cantidad_nueva - cantidad_actual
			mision["gelatina"] = mini(
				GELATINA_LIMO_REQUERIDA_MISION,
				int(mision.get("gelatina", 0)) + agregadas
			)
			misiones_jugadores[id] = mision
			_notificar_mision(id, "Gelatinas reunidas: %d/%d." % [mision["gelatina"], GELATINA_LIMO_REQUERIDA_MISION])
	_enviar(id, {
		"type": "inventory_updated",
		"items": _datos_inventario(id)
	})
	_guardar_partida_local(id)
	print("Botin otorgado al jugador ", id, ": ", id_objeto, " x", cantidad_nueva)


func _es_numero_finito(valor: Variant) -> bool:
	var tipo := typeof(valor)
	return tipo == TYPE_INT or (tipo == TYPE_FLOAT and is_finite(float(valor)))


func _numero_guardado(datos: Dictionary, clave: String, predeterminado: float) -> float:
	var valor: Variant = datos.get(clave, predeterminado)
	if not _es_numero_finito(valor):
		return predeterminado
	return float(valor)


func _normalizar_inventario(datos: Variant) -> Dictionary:
	var inventario: Dictionary = {}
	if typeof(datos) != TYPE_DICTIONARY:
		return inventario

	for clave in datos.keys():
		var id_objeto := str(clave)
		var definicion := CatalogoObjetos.obtener(id_objeto)
		if definicion.is_empty():
			continue
		var valor: Variant = datos[clave]
		if not _es_numero_finito(valor):
			continue
		var cantidad := int(clampf(float(valor), 0.0, float(definicion.get("max_pila", 1))))
		if cantidad > 0 and (inventario.has(id_objeto) or inventario.size() < CatalogoObjetos.CAPACIDAD_RANURAS):
			inventario[id_objeto] = cantidad
	return inventario


func _normalizar_oro(valor: Variant) -> int:
	if not _es_numero_finito(valor):
		return 0
	return int(clampf(float(valor), 0.0, float(ORO_MAXIMO)))


func _normalizar_progresion(datos: Variant) -> Dictionary:
	if typeof(datos) != TYPE_DICTIONARY:
		return {"level": 1, "xp": 0, "xp_to_next": XP_PARA_SUBIR_NIVEL, "strength": 0, "vitality": 0, "attribute_points": 0}
	var nivel := int(clampf(_numero_guardado(datos, "level", 1.0), 1.0, 1000000.0))
	var experiencia := int(clampf(_numero_guardado(datos, "xp", 0.0), 0.0, XP_PARA_SUBIR_NIVEL - 1.0))
	var puntos_ganados := maxi(0, nivel - 1)
	var fuerza := int(clampf(_numero_guardado(datos, "strength", 0.0), 0.0, float(puntos_ganados)))
	var vitalidad := int(clampf(_numero_guardado(datos, "vitality", 0.0), 0.0, float(puntos_ganados - fuerza)))
	return {
		"level": nivel,
		"xp": experiencia,
		"xp_to_next": XP_PARA_SUBIR_NIVEL,
		"strength": fuerza,
		"vitality": vitalidad,
		"attribute_points": puntos_ganados - fuerza - vitalidad
	}


func _normalizar_mision(datos: Variant) -> Dictionary:
	if typeof(datos) != TYPE_DICTIONARY:
		return _mision_inicial()
	var id_guardado: Variant = datos.get("id", "")
	var estado_guardado: Variant = datos.get("estado", "disponible")
	if typeof(id_guardado) != TYPE_STRING:
		return _mision_inicial()
	var id_mision := str(id_guardado)
	var estado := str(estado_guardado) if typeof(estado_guardado) == TYPE_STRING else "disponible"
	if not ["disponible", "activa", "completada"].has(estado):
		estado = "disponible"
	if id_mision == "caza_lobos":
		var lobos := int(clampf(_numero_guardado(datos, "lobos", 0.0), 0.0, float(LOBOS_REQUERIDOS_MISION)))
		if estado == "completada" or lobos >= LOBOS_REQUERIDOS_MISION:
			lobos = LOBOS_REQUERIDOS_MISION
			estado = "completada"
		return {
			"id": "caza_lobos",
			"estado": estado,
			"lobos": lobos,
			"objetivo_lobos": LOBOS_REQUERIDOS_MISION
		}
	if id_mision == "entrega_pieles":
		var pieles := int(clampf(_numero_guardado(datos, "pieles", 0.0), 0.0, float(PIEL_LOBO_REQUERIDAS_ENTREGA)))
		if estado == "completada":
			pieles = PIEL_LOBO_REQUERIDAS_ENTREGA
		return {
			"id": "entrega_pieles",
			"estado": estado,
			"pieles": pieles,
			"objetivo_pieles": PIEL_LOBO_REQUERIDAS_ENTREGA
		}
	if id_mision == "entrega_carne_jabali":
		var carne := int(clampf(_numero_guardado(datos, "carne", 0.0), 0.0, float(CARNE_JABALI_REQUERIDA_MISION)))
		if estado == "completada":
			carne = CARNE_JABALI_REQUERIDA_MISION
		return {
			"id": "entrega_carne_jabali",
			"estado": estado,
			"carne": carne,
			"objetivo_carne": CARNE_JABALI_REQUERIDA_MISION
		}
	if id_mision == "caza_jabalies":
		var jabalies := int(clampf(_numero_guardado(datos, "jabalies", 0.0), 0.0, float(JABALIES_REQUERIDOS_MISION)))
		if estado == "completada" or jabalies >= JABALIES_REQUERIDOS_MISION:
			jabalies = JABALIES_REQUERIDOS_MISION
			estado = "completada"
		return {"id": "caza_jabalies", "estado": estado, "jabalies": jabalies, "objetivo_jabalies": JABALIES_REQUERIDOS_MISION, "recompensa_reclamada": bool(datos.get("recompensa_reclamada", false))}
	if id_mision == "entrega_gelatina_limo":
		var gelatina := int(clampf(_numero_guardado(datos, "gelatina", 0.0), 0.0, float(GELATINA_LIMO_REQUERIDA_MISION)))
		if estado == "completada":
			gelatina = GELATINA_LIMO_REQUERIDA_MISION
		return {
			"id": "entrega_gelatina_limo",
			"estado": estado,
			"gelatina": gelatina,
			"objetivo_gelatina": GELATINA_LIMO_REQUERIDA_MISION
		}
	return _mision_inicial()


func _normalizar_equipamiento(datos: Variant, inventario: Dictionary) -> Dictionary:
	var equipo := {"arma": ""}
	if typeof(datos) != TYPE_DICTIONARY:
		return equipo
	var id_arma := str(datos.get("arma", ""))
	var definicion := CatalogoObjetos.obtener(id_arma)
	if definicion.get("tipo", "") == "equipo" and definicion.get("ranura", "") == "arma" and inventario.has(id_arma):
		equipo["arma"] = id_arma
	return equipo


func _normalizar_salud(datos: Variant, hp_maximo: int = VIDA_MAXIMA_JUGADOR) -> Dictionary:
	var vida_maxima := maxi(1, hp_maximo)
	var hp := vida_maxima
	if typeof(datos) == TYPE_DICTIONARY:
		hp = int(clampf(_numero_guardado(datos, "hp", float(vida_maxima)), 0.0, float(vida_maxima)))
	if hp <= 0:
		hp = vida_maxima
	return {"hp": hp, "hp_max": vida_maxima, "muerto": false}


func _posicion_guardada_valida(datos: Variant) -> bool:
	if typeof(datos) != TYPE_DICTIONARY:
		return false
	var x := _numero_guardado(datos, "x", INF)
	var y := _numero_guardado(datos, "y", INF)
	var z := _numero_guardado(datos, "z", INF)
	var limite := GeneradorTerreno.TAMANO_MUNDO * 0.5
	return is_finite(x) and is_finite(y) and is_finite(z) and absf(x) <= limite and absf(z) <= limite and y >= -20.0 and y <= 100.0


func _yaw_guardado(datos: Variant) -> float:
	if typeof(datos) != TYPE_DICTIONARY:
		return 0.0
	var yaw := _numero_guardado(datos, "yaw", 0.0)
	if not is_finite(yaw) or absf(yaw) > 10000.0:
		return 0.0
	return wrapf(yaw, -PI, PI)


func _leer_partida_local() -> Dictionary:
	if not modo_individual or not FileAccess.file_exists(ruta_guardado_local):
		return {}
	var archivo := FileAccess.open(ruta_guardado_local, FileAccess.READ)
	if archivo == null:
		push_warning("No se pudo leer la partida local guardada.")
		return {}
	var parser := JSON.new()
	var error_parseo := parser.parse(archivo.get_as_text())
	archivo.close()
	if error_parseo != OK:
		push_warning("El archivo de partida local está dañado (%s); se inicia una partida nueva." % parser.get_error_message())
		return {}
	var datos: Variant = parser.data
	if typeof(datos) != TYPE_DICTIONARY or not _es_numero_finito(datos.get("version", 0)) or float(datos.get("version", 0)) != 1.0:
		push_warning("El archivo de partida local no tiene un formato compatible; se inicia una partida nueva.")
		return {}
	return datos


func _guardar_partida_local(id: int) -> void:
	if not modo_individual or not jugadores.has(id):
		return
	var jugador: Dictionary = jugadores[id]
	var datos := {
		"version": 1,
		"position": {
			"x": jugador["x"],
			"y": jugador["y"],
			"z": jugador["z"],
			"yaw": jugador.get("yaw", 0.0)
		},
		"inventory": _datos_inventario(id),
		"gold": _datos_oro(id),
		"progression": _datos_progresion(id),
		"health": _datos_salud_jugador(id),
		"quest": _datos_mision(id),
		"equipment": _datos_equipamiento(id)
	}
	var archivo := FileAccess.open(ruta_guardado_local, FileAccess.WRITE)
	if archivo == null:
		push_error("No se pudo guardar la partida local: %s" % FileAccess.get_open_error())
		return
	archivo.store_string(JSON.stringify(datos))
	archivo.flush()
	if archivo.get_error() != OK:
		push_error("Error al escribir la partida local.")
	archivo.close()


func _guardar_partidas_locales() -> void:
	if not modo_individual:
		return
	for id_var in jugadores.keys():
		_guardar_partida_local(int(id_var))


func _al_conectar(id: int) -> void:
	if jugadores.size() >= MAX_JUGADORES:
		print("Servidor lleno. Rechazando jugador: ", id)

		_enviar_texto(id, "SERVIDOR_LLENO")
		rechazos_pendientes[id] = TIEMPO_RECHAZO
		return

	var spawn_slot := _obtener_slot_aparicion()

	var partida_guardada := _leer_partida_local()
	inventarios[id] = _normalizar_inventario(partida_guardada.get("inventory", {}))
	oro_jugadores[id] = _normalizar_oro(partida_guardada.get("gold", 0))
	progresion_jugadores[id] = _normalizar_progresion(partida_guardada.get("progression", {}))
	misiones_jugadores[id] = _normalizar_mision(partida_guardada.get("quest", {}))
	equipamiento_jugadores[id] = _normalizar_equipamiento(
		partida_guardada.get("equipment", {}),
		inventarios[id]
	)

	var posicion := GeneradorTerreno.posicion_aparicion(
		spawn_slot,
		ruido_terreno,
		ruido_detalle
	)
	var posicion_guardada: Variant = partida_guardada.get("position", {})
	var yaw := 0.0
	if _posicion_guardada_valida(posicion_guardada):
		posicion = Vector3(
			float(posicion_guardada["x"]),
			float(posicion_guardada["y"]),
			float(posicion_guardada["z"])
		)
		yaw = _yaw_guardado(posicion_guardada)

	salud_jugadores[id] = _normalizar_salud(partida_guardada.get("health", {}), _vida_maxima_jugador(id))
	datos_spawn_jugadores[id] = posicion

	var altura_base := _altura_terreno(
		posicion.x,
		posicion.z
	) + ALTURA_BASE_JUGADOR

	jugadores[id] = {
		"x": posicion.x,
		"y": posicion.y,
		"z": posicion.z,
		"yaw": yaw,
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
		"yaw": yaw,
		"players": lista_jugadores,
		"world": _datos_mundo(),
		"entities": _lista_entidades(),
		"inventory": _datos_inventario(id),
		"gold": _datos_oro(id),
		"progression": _datos_progresion(id),
		"player_health": _datos_salud_jugador(id),
		"quest": _datos_mision(id),
		"equipment": _datos_equipamiento(id)
	})

	_difundir({
		"type": "player_joined",
		"id": id,
		"x": posicion.x,
		"y": posicion.y,
		"z": posicion.z,
		"yaw": yaw,
		"sprint": false,
		"en_el_aire": false
	}, id)

	print("Jugador conectado: ", id, " | ", jugadores.size(), "/", MAX_JUGADORES)


func _procesar_movimiento(id: int, datos: Dictionary) -> void:
	if not jugadores.has(id):
		return

	var salud_jugador := _datos_salud_jugador(id)
	if bool(salud_jugador.get("muerto", false)):
		_corregir_posicion(id)
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
		_guardar_partida_local(id)
		jugadores.erase(id)

		_difundir({
			"type": "player_left",
			"id": id
		})

		print("Jugador desconectado: ", id, " | ", jugadores.size(), "/", MAX_JUGADORES)

	rechazos_pendientes.erase(id)
	tiempos_ultimo_ataque.erase(id)
	tiempos_ultimo_golpe_pesado.erase(id)
	inventarios.erase(id)
	oro_jugadores.erase(id)
	progresion_jugadores.erase(id)
	salud_jugadores.erase(id)
	misiones_jugadores.erase(id)
	equipamiento_jugadores.erase(id)
	datos_spawn_jugadores.erase(id)
	temporizadores_respawn_jugadores.erase(id)
	proteccion_respawn_jugadores.erase(id)


func _enviar(id: int, datos: Dictionary) -> void:
	if servidor.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		return
	servidor.set_target_peer(id)

	var error := servidor.put_packet(
		JSON.stringify(datos).to_utf8_buffer()
	)

	servidor.set_target_peer(MultiplayerPeer.TARGET_PEER_BROADCAST)

	if error != OK:
		push_error("Error enviando datos al jugador: %s" % id)


func _enviar_texto(id: int, mensaje: String) -> void:
	if servidor.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		return
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
	_guardar_partidas_locales()
	servidor.close()
