extends SceneTree

const EscenaPartida := preload("res://Mapa1/Escena1.tscn")

var resultado_ataque_recibido: Dictionary = {}
var resultado_compra_recibido: Dictionary = {}


func _registrar_resultado_ataque(datos: Dictionary) -> void:
	resultado_ataque_recibido = datos.duplicate(true)


func _registrar_resultado_compra(datos: Dictionary) -> void:
	resultado_compra_recibido = datos.duplicate(true)


func _initialize() -> void:
	call_deferred("_ejecutar_prueba")


func _borrar_guardado_temporal(ruta: String) -> void:
	if not FileAccess.file_exists(ruta):
		return
	var ruta_absoluta := ruta if ruta.is_absolute_path() else ProjectSettings.globalize_path(ruta)
	var error := DirAccess.remove_absolute(ruta_absoluta)
	if error != OK:
		push_error("No se pudo borrar el guardado temporal: %s" % ruta)


func _abrir_sesion(ruta_guardado: String) -> Dictionary:
	var partida = EscenaPartida.instantiate()
	root.add_child(partida)
	current_scene = partida
	var servidor: Node = partida.get_node_or_null("ServidorLocal")
	var cliente: Node = partida.get("nodo_multijugador")
	if servidor == null or cliente == null:
		return {"partida": partida, "servidor": servidor, "cliente": cliente, "conectado": false}

	servidor.set("ruta_guardado_local", ruta_guardado)
	var conectado := false
	var limite_ms := Time.get_ticks_msec() + 10000
	while Time.get_ticks_msec() < limite_ms:
		await process_frame
		if bool(cliente.get("conectado")) and int(cliente.get("id_local")) > 0 and bool(cliente.get("mundo_validado")):
			if servidor.get("jugadores").size() == 1:
				conectado = true
				break
		await create_timer(0.05).timeout
	return {"partida": partida, "servidor": servidor, "cliente": cliente, "conectado": conectado}


func _cerrar_sesion(partida: Node) -> void:
	if is_instance_valid(partida):
		if current_scene == partida:
			current_scene = null
		partida.queue_free()
	await process_frame
	await create_timer(1.25).timeout


func _ejecutar_prueba() -> void:
	var ruta_guardado := "C:/Users/Bruker/Documents/Codex/classicrpg_prueba_partida_%d.json" % Time.get_ticks_usec()
	var errores: Array[String] = []
	var primera_sesion: Dictionary = await _abrir_sesion(ruta_guardado)
	var partida_primera: Node = primera_sesion.get("partida")
	var servidor_primero: Node = primera_sesion.get("servidor")
	var cliente_primero: Node = primera_sesion.get("cliente")
	var puerto_primero := int(servidor_primero.get("puerto_escucha")) if servidor_primero != null else 0
	if servidor_primero == null or cliente_primero == null:
		errores.append("la escena inicial no creó servidor local y cliente")
	elif not bool(servidor_primero.get("modo_individual")):
		errores.append("el servidor integrado no activó el modo individual")
	if not bool(primera_sesion.get("conectado", false)):
		errores.append("el único cliente no conectó y validó el mundo en 10 segundos")
	if partida_primera != null:
		partida_primera.call("_abrir_pausa")
		if not bool(partida_primera.get("pausa_abierta")) or not paused or partida_primera.get("panel_pausa") == null:
			errores.append("la tecla de pausa no mostró el panel ni pausó el árbol")
		partida_primera.call("_cerrar_pausa")
		if bool(partida_primera.get("pausa_abierta")) or paused:
			errores.append("reanudar no cerró la pausa del árbol")
	if bool(primera_sesion.get("conectado", false)):
		var mision_inicial: Dictionary = cliente_primero.get("mision_actual")
		if str(mision_inicial.get("id", "")) != "caza_lobos" or str(mision_inicial.get("estado", "")) != "disponible":
			errores.append("el cliente no recibió la misión inicial")
		var entidades_remotas: Dictionary = cliente_primero.get("entidades_remotas")
		if not entidades_remotas.has(5) or str(entidades_remotas[5].name) != "EntidadRemota_5":
			errores.append("el cliente individual no creó la representación remota del limo")
		else:
			print("OK: el único cliente recibió y creó visualmente el limo de la zona.")
		print("OK: mapa, servidor local y un cliente conectaron sin proceso ni segundo cliente.")

		var id_habilidad := int(cliente_primero.get("id_local"))
		var entidades_habilidad: Dictionary = servidor_primero.get("entidades")
		var lobo_habilidad: Dictionary = entidades_habilidad.get(3, {})
		var jugadores_habilidad: Dictionary = servidor_primero.get("jugadores")
		var posicion_habilidad: Dictionary = jugadores_habilidad.get(id_habilidad, {})
		lobo_habilidad["x"] = float(posicion_habilidad.get("x", 0.0))
		lobo_habilidad["y"] = float(posicion_habilidad.get("y", 0.0))
		lobo_habilidad["z"] = float(posicion_habilidad.get("z", 0.0))
		lobo_habilidad["hp"] = 60
		lobo_habilidad["estado"] = "patrullando"
		lobo_habilidad["activo"] = true
		entidades_habilidad[3] = lobo_habilidad
		servidor_primero.set("entidades", entidades_habilidad)
		resultado_ataque_recibido.clear()
		cliente_primero.resultado_ataque.connect(_registrar_resultado_ataque)
		cliente_primero.set("id_objetivo", 3)
		cliente_primero.atacar_objetivo("golpe_pesado")
		var limite_habilidad := Time.get_ticks_msec() + 5000
		while resultado_ataque_recibido.is_empty() and Time.get_ticks_msec() < limite_habilidad:
			await process_frame
		var entidades_tras_habilidad: Dictionary = servidor_primero.get("entidades")
		var lobo_tras_habilidad: Dictionary = entidades_tras_habilidad.get(3, {})
		if not bool(resultado_ataque_recibido.get("success", false)) or str(resultado_ataque_recibido.get("skill_id", "")) != "golpe_pesado" or int(resultado_ataque_recibido.get("damage", 0)) != 30 or int(lobo_tras_habilidad.get("hp", 0)) != 30:
			errores.append("el golpe pesado no recorrió cliente-servidor local con 30 de daño a nivel 1")
		else:
			print("OK: golpe pesado llegó por la conexión local y aplicó daño autoritativo.")

		# El descarte debe atravesar la lista del HUD, el cliente WebSocket y el servidor local.
		var inventario_prueba: Dictionary = servidor_primero.get("inventarios")
		inventario_prueba[id_habilidad] = {}
		servidor_primero.set("inventarios", inventario_prueba)
		servidor_primero.call("_agregar_objeto_inventario", id_habilidad, "gelatina_limo", 2)
		var lista_inventario: ItemList = partida_primera.get("lista_inventario")
		var boton_descartar: Button = partida_primera.get("boton_descartar_objeto")
		var dialogo_descartar: ConfirmationDialog = partida_primera.get("dialogo_descartar_objeto")
		var indice_gelatina := -1
		var limite_inventario := Time.get_ticks_msec() + 3000
		while indice_gelatina < 0 and Time.get_ticks_msec() < limite_inventario:
			if lista_inventario != null:
				for indice in range(lista_inventario.item_count):
					if str(lista_inventario.get_item_metadata(indice)) == "gelatina_limo":
						indice_gelatina = indice
						break
			await process_frame
		if indice_gelatina < 0 or boton_descartar == null or dialogo_descartar == null:
			errores.append("el HUD individual no mostró el objeto descartable")
		else:
			lista_inventario.select(indice_gelatina)
			partida_primera.call("_al_seleccionar_objeto_inventario", indice_gelatina)
			if boton_descartar.disabled:
				errores.append("seleccionar un objeto con controles habilitados no habilitó el botón de descarte")
			else:
				boton_descartar.pressed.emit()
				if not dialogo_descartar.visible:
					errores.append("el botón de descarte no pidió confirmación antes de destruir el objeto")
				else:
					dialogo_descartar.get_cancel_button().pressed.emit()
					await process_frame
					var inventario_tras_cancelar: Dictionary = servidor_primero.get("inventarios").get(id_habilidad, {})
					if int(inventario_tras_cancelar.get("gelatina_limo", 0)) != 2:
						errores.append("cancelar el diálogo alteró el inventario")
					else:
						boton_descartar.pressed.emit()
						dialogo_descartar.get_ok_button().pressed.emit()
						var limite_descarte := Time.get_ticks_msec() + 5000
						while Time.get_ticks_msec() < limite_descarte:
							var inventario_cliente: Dictionary = cliente_primero.get("inventario")
							var inventario_servidor: Dictionary = servidor_primero.get("inventarios").get(id_habilidad, {})
							if int(inventario_cliente.get("gelatina_limo", 0)) == 1 and int(inventario_servidor.get("gelatina_limo", 0)) == 1:
								break
							await process_frame
						var inventario_cliente_final: Dictionary = cliente_primero.get("inventario")
						var inventario_servidor_final: Dictionary = servidor_primero.get("inventarios").get(id_habilidad, {})
						if int(inventario_cliente_final.get("gelatina_limo", 0)) != 1 or int(inventario_servidor_final.get("gelatina_limo", 0)) != 1:
							errores.append("confirmar el descarte no quitó una unidad entre cliente y servidor por WebSocket")
						else:
							print("OK: cancelar preservó el inventario y confirmar descartó una unidad por la conexión individual.")

		# Asignar atributos desde el HUD actualiza progresión y salud por el servidor.
		var progresion_atributos: Dictionary = servidor_primero.get("progresion_jugadores")
		progresion_atributos[id_habilidad] = {"level": 3, "xp": 25, "xp_to_next": 100, "strength": 0, "vitality": 0}
		servidor_primero.set("progresion_jugadores", progresion_atributos)
		var salud_atributos: Dictionary = servidor_primero.get("salud_jugadores")
		salud_atributos[id_habilidad] = {"hp": 70, "hp_max": 100, "muerto": false}
		servidor_primero.set("salud_jugadores", salud_atributos)
		var progresion_inicial_atributos: Dictionary = servidor_primero.call("_datos_progresion", id_habilidad)
		servidor_primero.call("_enviar", id_habilidad, {"type": "progression_updated", "progression": progresion_inicial_atributos})
		var salud_inicial_atributos: Dictionary = servidor_primero.call("_datos_salud_jugador", id_habilidad)
		salud_inicial_atributos["type"] = "player_health_updated"
		servidor_primero.call("_enviar", id_habilidad, salud_inicial_atributos)
		var boton_fuerza: Button = partida_primera.get("boton_mejorar_fuerza")
		var boton_vitalidad: Button = partida_primera.get("boton_mejorar_vitalidad")
		if boton_fuerza == null or boton_vitalidad == null:
			errores.append("el HUD no creó botones de atributos")
		else:
			var limite_puntos := Time.get_ticks_msec() + 3000
			while int(cliente_primero.get("progresion").get("attribute_points", 0)) != 2 and Time.get_ticks_msec() < limite_puntos:
				await process_frame
			if boton_fuerza.disabled:
				errores.append("el HUD no habilitó la asignación de puntos heredados de los niveles")
			else:
				boton_fuerza.pressed.emit()
				var limite_fuerza := Time.get_ticks_msec() + 5000
				while int(servidor_primero.call("_datos_progresion", id_habilidad).get("strength", 0)) != 1 and Time.get_ticks_msec() < limite_fuerza:
					await process_frame
				if int(cliente_primero.get("progresion").get("strength", 0)) != 1 or int(cliente_primero.get("progresion").get("attribute_points", -1)) != 1:
					errores.append("el botón Fuerza no asignó un punto en el servidor")
				else:
					boton_vitalidad.pressed.emit()
					var limite_vitalidad := Time.get_ticks_msec() + 5000
					while int(servidor_primero.call("_datos_progresion", id_habilidad).get("vitality", 0)) != 1 and Time.get_ticks_msec() < limite_vitalidad:
						await process_frame
					var salud_vitalidad_cliente: Dictionary = cliente_primero.get("salud_local")
					var progreso_vitalidad_cliente: Dictionary = cliente_primero.get("progresion")
					if int(salud_vitalidad_cliente.get("hp", 0)) != 80 or int(salud_vitalidad_cliente.get("hp_max", 0)) != 110 or int(progreso_vitalidad_cliente.get("attribute_points", -1)) != 0:
						errores.append("el botón Vitalidad no actualizó puntos y vida por WebSocket")
					else:
						print("OK: Fuerza y Vitalidad se asignaron desde el HUD y el servidor sincronizó daño/vida por WebSocket.")

		# La tienda del HUD compra una poción por WebSocket y actualiza el oro persistible.
		var id_tienda := int(cliente_primero.get("id_local"))
		var boton_tienda: Button = partida_primera.get("boton_comprar_pocion")
		var etiqueta_oro: Label = partida_primera.get("etiqueta_oro")
		if boton_tienda == null or etiqueta_oro == null:
			errores.append("el HUD no creó el saldo y el botón de compra")
		else:
			var estados_tienda: Dictionary = servidor_primero.get("jugadores")
			var estado_tienda: Dictionary = estados_tienda.get(id_tienda, {})
			estado_tienda["x"] = 3.0
			estado_tienda["z"] = 0.0
			estados_tienda[id_tienda] = estado_tienda
			servidor_primero.set("jugadores", estados_tienda)
			var jugador_tienda: Node3D = cliente_primero.get("jugador_local")
			if is_instance_valid(jugador_tienda):
				var posicion_tienda := jugador_tienda.global_position
				jugador_tienda.global_position = Vector3(3.0, posicion_tienda.y, 0.0)
			servidor_primero.call("_agregar_oro", id_tienda, 40)
			var limite_saldo := Time.get_ticks_msec() + 3000
			while int(cliente_primero.get("oro")) != 40 and Time.get_ticks_msec() < limite_saldo:
				await process_frame
			if int(cliente_primero.get("oro")) != 40 or etiqueta_oro.text != "Oro: 40":
				errores.append("el HUD no reflejó el saldo de oro recibido del servidor")
			resultado_compra_recibido.clear()
			cliente_primero.resultado_compra.connect(_registrar_resultado_compra)
			boton_tienda.pressed.emit()
			var limite_compra := Time.get_ticks_msec() + 5000
			while (resultado_compra_recibido.is_empty() or int(cliente_primero.get("oro")) != 20) and Time.get_ticks_msec() < limite_compra:
				await process_frame
			var inventario_compra: Dictionary = cliente_primero.get("inventario")
			if not bool(resultado_compra_recibido.get("success", false)) or int(cliente_primero.get("oro")) != 20 or int(inventario_compra.get("pocion_curativa", 0)) != 1 or etiqueta_oro.text != "Oro: 20":
				errores.append("la compra desde el HUD no cobró oro, entregó la poción y actualizó ambos estados")
			else:
				print("OK: el botón de tienda compró una poción al Habitante y sincronizó inventario/oro por WebSocket.")
			cliente_primero.resultado_compra.disconnect(_registrar_resultado_compra)

		var id_local := int(cliente_primero.get("id_local"))
		# Evita que el cliente real del test sobrescriba el estado artificial que se persiste.
		var jugador_prueba: Node = cliente_primero.get("jugador_local")
		if is_instance_valid(jugador_prueba):
			jugador_prueba.set("controles_habilitados", false)
		var jugadores: Dictionary = servidor_primero.get("jugadores")
		var estado_jugador: Dictionary = jugadores[id_local]
		estado_jugador["x"] = -7.25
		estado_jugador["y"] = 1.5
		estado_jugador["z"] = 11.75
		estado_jugador["yaw"] = 1.25
		jugadores[id_local] = estado_jugador
		servidor_primero.set("jugadores", jugadores)
		var inventarios: Dictionary = servidor_primero.get("inventarios")
		inventarios[id_local] = {"piel_lobo": 2, "espada_del_habitante": 1, "pocion_curativa": 1}
		servidor_primero.set("inventarios", inventarios)
		var progresion: Dictionary = servidor_primero.get("progresion_jugadores")
		progresion[id_local] = {"level": 3, "xp": 25, "xp_to_next": 100, "strength": 1, "vitality": 1, "attribute_points": 0}
		servidor_primero.set("progresion_jugadores", progresion)
		var salud: Dictionary = servidor_primero.get("salud_jugadores")
		salud[id_local] = {"hp": 75, "hp_max": 110, "muerto": false}
		servidor_primero.set("salud_jugadores", salud)
		var misiones: Dictionary = servidor_primero.get("misiones_jugadores")
		misiones[id_local] = {"id": "entrega_pieles", "estado": "activa", "pieles": 2, "objetivo_pieles": 3}
		servidor_primero.set("misiones_jugadores", misiones)
		var equipo: Dictionary = servidor_primero.get("equipamiento_jugadores")
		equipo[id_local] = {"arma": "espada_del_habitante"}
		servidor_primero.set("equipamiento_jugadores", equipo)

	await _cerrar_sesion(partida_primera)
	if not FileAccess.file_exists(ruta_guardado):
		errores.append("cerrar la partida no escribió el guardado individual")
	else:
		var archivo := FileAccess.open(ruta_guardado, FileAccess.READ)
		if archivo == null:
			errores.append("no se pudo leer el guardado producido al cerrar")
		else:
			var datos = JSON.parse_string(archivo.get_as_text())
			archivo.close()
			if typeof(datos) != TYPE_DICTIONARY or int(datos.get("version", 0)) != 1:
				errores.append("el archivo final no contiene una partida versión 1 válida")

	var segunda_sesion: Dictionary = await _abrir_sesion(ruta_guardado)
	var partida_segunda: Node = segunda_sesion.get("partida")
	var servidor_segundo: Node = segunda_sesion.get("servidor")
	var cliente_segundo: Node = segunda_sesion.get("cliente")
	if servidor_segundo != null and int(servidor_segundo.get("puerto_escucha")) == puerto_primero:
		errores.append("la segunda sesión local reutilizó el puerto de la sesión anterior")
	if not bool(segunda_sesion.get("conectado", false)):
		errores.append("el cliente no pudo reabrir la partida guardada")
	else:
		var inventario_cargado: Dictionary = cliente_segundo.get("inventario")
		var progresion_cargada: Dictionary = cliente_segundo.get("progresion")
		var salud_cargada: Dictionary = cliente_segundo.get("salud_local")
		var mision_cargada: Dictionary = cliente_segundo.get("mision_actual")
		var equipo_cargado: Dictionary = cliente_segundo.get("equipamiento_local")
		var etiqueta_oro_cargada: Label = partida_segunda.get("etiqueta_oro")
		var jugador_local: Node3D = cliente_segundo.get("jugador_local")
		if int(inventario_cargado.get("piel_lobo", 0)) != 2 or int(inventario_cargado.get("espada_del_habitante", 0)) != 1 or int(inventario_cargado.get("pocion_curativa", 0)) != 1:
			errores.append("el segundo inicio no restauró el inventario")
		if int(cliente_segundo.get("oro")) != 20 or etiqueta_oro_cargada == null or etiqueta_oro_cargada.text != "Oro: 20":
			errores.append("el segundo inicio no restauró el oro y su HUD")
		if int(progresion_cargada.get("level", 0)) != 3 or int(progresion_cargada.get("xp", -1)) != 25:
			errores.append("el segundo inicio no restauró nivel y XP")
		if int(progresion_cargada.get("strength", -1)) != 1 or int(progresion_cargada.get("vitality", -1)) != 1 or int(progresion_cargada.get("attribute_points", -1)) != 0:
			errores.append("el segundo inicio no restauró los atributos asignados")
		if int(salud_cargada.get("hp", 0)) != 75:
			errores.append("el segundo inicio no restauró HP")
		if int(salud_cargada.get("hp_max", 0)) != 110:
			errores.append("el segundo inicio no restauró la vida máxima derivada de Vitalidad")
		if str(mision_cargada.get("id", "")) != "entrega_pieles" or int(mision_cargada.get("pieles", 0)) != 2:
			errores.append("el segundo inicio no restauró la misión activa")
		if str(equipo_cargado.get("arma", "")) != "espada_del_habitante":
			errores.append("el segundo inicio no restauró el arma equipada")
		var posicion_restaurada := jugador_local.global_position
		var error_horizontal := Vector2(posicion_restaurada.x + 7.25, posicion_restaurada.z - 11.75).length()
		if error_horizontal > 0.01:
			errores.append("el segundo inicio no restauró la posición del personaje")
		await create_timer(0.25).timeout
		var etiqueta_mision: Label = partida_segunda.get("etiqueta_mision")
		if etiqueta_mision == null or not etiqueta_mision.text.contains("Entrega de pieles") or not etiqueta_mision.text.contains("2 / 3"):
			errores.append("el HUD no reflejó la misión restaurada; texto actual: <%s>" % (etiqueta_mision.text if etiqueta_mision != null else "null"))
		if servidor_segundo == null or servidor_segundo.get("jugadores").size() != 1:
			errores.append("la partida restaurada no mantuvo un solo jugador")
		print("OK: reabrir la escena restaura inventario, progreso, vida, misión, equipo, posición y HUD.")

	if is_instance_valid(partida_segunda) and errores.is_empty():
		partida_segunda.call("_abrir_pausa")
		var panel: Control = partida_segunda.get("panel_pausa")
		var columna: VBoxContainer = panel.get_child(1).get_child(0)
		var boton_volver: Button = columna.get_child(2)
		if boton_volver.text != "Guardar y volver al título":
			errores.append("el panel de pausa no presenta la acción de volver al título")
		else:
			boton_volver.pressed.emit()
			var limite_menu := Time.get_ticks_msec() + 5000
			while (current_scene == null or current_scene == partida_segunda) and Time.get_ticks_msec() < limite_menu:
				await process_frame
				await create_timer(0.05).timeout
			if current_scene == null or current_scene.scene_file_path != "res://MenuInicio.tscn":
				errores.append("Guardar y volver no cargó la escena del menú de inicio")
			if not FileAccess.file_exists(ruta_guardado):
				errores.append("Guardar y volver cargó el menú antes de escribir el guardado temporal")
			else:
				var archivo_guardado := FileAccess.open(ruta_guardado, FileAccess.READ)
				if archivo_guardado == null:
					errores.append("no se pudo leer el guardado escrito al volver al título")
				else:
					var datos_guardados = JSON.parse_string(archivo_guardado.get_as_text())
					archivo_guardado.close()
					if typeof(datos_guardados) != TYPE_DICTIONARY or int(datos_guardados.get("version", 0)) != 1:
						errores.append("Guardar y volver no escribió un JSON de partida válido")
					else:
						var inventario_guardado: Dictionary = datos_guardados.get("inventory", {})
						var oro_guardado := int(datos_guardados.get("gold", -1))
						var mision_guardada: Dictionary = datos_guardados.get("quest", {})
						if int(inventario_guardado.get("piel_lobo", 0)) != 2 or int(inventario_guardado.get("espada_del_habitante", 0)) != 1 or int(inventario_guardado.get("pocion_curativa", 0)) != 1:
							errores.append("Guardar y volver no persistió el inventario esperado")
						if oro_guardado != 20:
							errores.append("Guardar y volver no persistió el saldo esperado")
						if str(mision_guardada.get("id", "")) != "entrega_pieles" or int(mision_guardada.get("pieles", 0)) != 2:
							errores.append("Guardar y volver no persistió el progreso de misión esperado")
						if errores.is_empty():
							print("OK: el botón guardó JSON válido con inventario/misión y volvió al menú de inicio.")
	else:
		await _cerrar_sesion(partida_segunda)
	_borrar_guardado_temporal(ruta_guardado)

	if not errores.is_empty():
		for error in errores:
			push_error("Prueba de partida individual: " + error)
		quit(1)
		return

	print("OK: la partida individual guarda y carga al cerrar/reabrir; los temporales quedaron eliminados.")
	quit(0)
