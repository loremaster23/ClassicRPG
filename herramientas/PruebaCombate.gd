extends SceneTree

const ServidorScript := preload("res://scripts/servidor/Servidor.gd")
const CatalogoObjetosScript := preload("res://scripts/compartido/CatalogoObjetos.gd")

var ultimo_resultado: Dictionary = {}

func _al_recibir_ataque(_id: int, res: Dictionary) -> void:
	ultimo_resultado = res.duplicate(true)


func _borrar_guardado_prueba(ruta: String) -> void:
	if not FileAccess.file_exists(ruta):
		return
	var ruta_absoluta := ruta if ruta.is_absolute_path() else ProjectSettings.globalize_path(ruta)
	var error := DirAccess.remove_absolute(ruta_absoluta)
	if error != OK:
		push_error("No se pudo borrar el archivo temporal de persistencia: %s" % ruta)


func _escribir_guardado_prueba(ruta: String, contenido: String) -> bool:
	var archivo := FileAccess.open(ruta, FileAccess.WRITE)
	if archivo == null:
		push_error("No se pudo abrir temporal de prueba (%s): %s" % [ruta, FileAccess.get_open_error()])
		return false
	archivo.store_string(contenido)
	archivo.flush()
	var escrito := archivo.get_error() == OK
	archivo.close()
	return escrito


func _initialize() -> void:
	var servidor = ServidorScript.new()
	servidor._inicializar_mundo()
	servidor.ataque_procesado.connect(_al_recibir_ataque)

	var id_jugador := 10
	servidor.jugadores[id_jugador] = {
		"x": -3.0,
		"y": 0.0,
		"z": 1.0,
		"yaw": 0.0,
		"sprint": false,
		"en_el_aire": false
	}

	# 1. Ataque a objetivo inexistente
	ultimo_resultado.clear()
	servidor._procesar_ataque(id_jugador, {"target_id": 999})
	if ultimo_resultado.get("success", true) != false or ultimo_resultado.get("reason", "") != "invalid_target":
		push_error("Error: esperaba invalid_target para entidad 999.")
		servidor.free()
		quit(1)
		return

	# 2. Ataque fuera de rango
	ultimo_resultado.clear()
	servidor.jugadores[id_jugador]["z"] = 25.0
	servidor._procesar_ataque(id_jugador, {"target_id": 3})
	if ultimo_resultado.get("success", true) != false or ultimo_resultado.get("reason", "") != "out_of_range":
		push_error("Error: esperaba out_of_range para atacante a 25 metros.")
		servidor.free()
		quit(1)
		return

	# 3. Ataque exitoso en rango
	ultimo_resultado.clear()
	servidor.jugadores[id_jugador]["z"] = 1.0
	servidor._procesar_ataque(id_jugador, {"target_id": 3})
	if not bool(ultimo_resultado.get("success", false)):
		push_error("Error: el ataque cuerpo a cuerpo debio tener exito.")
		servidor.free()
		quit(1)
		return

	var danio: int = int(ultimo_resultado.get("damage", 0))
	var hp_restante: int = int(ultimo_resultado.get("target_hp", 0))
	if danio != 15 or hp_restante != 45:
		push_error("Error: danio esperado 15 y hp 45, recibido danio %d hp %d" % [danio, hp_restante])
		servidor.free()
		quit(1)
		return

	# 4. Cooldown de ataque inmediato
	ultimo_resultado.clear()
	servidor._procesar_ataque(id_jugador, {"target_id": 3})
	if ultimo_resultado.get("success", true) != false or ultimo_resultado.get("reason", "") != "on_cooldown":
		push_error("Error: ataque inmediato debio fallar por on_cooldown.")
		servidor.free()
		quit(1)
		return

	# 5. Muerte de la entidad cuando HP llega a 0
	ultimo_resultado.clear()
	servidor.tiempos_ultimo_ataque[id_jugador] = -100.0
	servidor.entidades[3]["hp"] = 10
	servidor._procesar_ataque(id_jugador, {"target_id": 3})
	if not bool(ultimo_resultado.get("success", false)) or int(ultimo_resultado.get("target_hp", 1)) != 0:
		push_error("Error: golpe letal debio reducir vida a 0.")
		servidor.free()
		quit(1)
		return

	if ultimo_resultado.get("target_state", "") != "muerto":
		push_error("Error: el estado enviado debio ser 'muerto'.")
		servidor.free()
		quit(1)
		return

	if servidor.entidades[3]["activo"] != false or servidor.entidades[3]["estado"] != "muerto":
		push_error("Error: la entidad 3 en el servidor debio quedar inactiva y muerta.")
		servidor.free()
		quit(1)
		return
	var botin: Dictionary = servidor.inventarios.get(id_jugador, {})
	if int(botin.get("colmillo_lobo", 0)) != 1 or int(botin.get("piel_lobo", 0)) != 1:
		push_error("Error: el atacante final debio recibir exactamente un colmillo y una piel.")
		servidor.free()
		quit(1)
		return

	var progreso: Dictionary = servidor.progresion_jugadores.get(id_jugador, {})
	if int(progreso.get("xp", 0)) != 25 or int(ultimo_resultado.get("xp_gained", 0)) != 25:
		push_error("Error: el atacante final debio recibir 25 XP.")
		servidor.free()
		quit(1)
		return

	# 5.1 Limites de capacidad y apilamiento del inventario
	var inventario_apilable: Dictionary = {"colmillo_lobo": 1}
	for indice in range(CatalogoObjetosScript.CAPACIDAD_RANURAS - 1):
		inventario_apilable["slot_prueba_%02d" % indice] = 1
	if inventario_apilable.size() != CatalogoObjetosScript.CAPACIDAD_RANURAS:
		push_error("Error: la prueba de apilado debio llenar exactamente 20 ranuras.")
		servidor.free()
		quit(1)
		return

	if servidor._inventario_tiene_espacio(inventario_apilable, "piel_lobo"):
		push_error("Error: no debia haber espacio para un objeto nuevo con las 20 ranuras ocupadas.")
		servidor.free()
		quit(1)
		return

	servidor.inventarios[id_jugador] = inventario_apilable.duplicate(true)
	servidor._agregar_objeto_inventario(id_jugador, "colmillo_lobo", 1)
	var inventario_despues_de_apilar: Dictionary = servidor.inventarios.get(id_jugador, {})
	if int(inventario_despues_de_apilar.get("colmillo_lobo", 0)) != 2 or inventario_despues_de_apilar.size() != CatalogoObjetosScript.CAPACIDAD_RANURAS:
		push_error("Error: un objeto existente debio apilarse sin consumir otra ranura.")
		servidor.free()
		quit(1)
		return

	var inventario_lleno: Dictionary = {}
	for indice in range(CatalogoObjetosScript.CAPACIDAD_RANURAS):
		inventario_lleno["slot_lleno_%02d" % indice] = 1
	servidor.inventarios[id_jugador] = inventario_lleno.duplicate(true)
	servidor._agregar_objeto_inventario(id_jugador, "piel_lobo", 1)
	var inventario_despues_de_rechazo: Dictionary = servidor.inventarios.get(id_jugador, {})
	if inventario_despues_de_rechazo.has("piel_lobo") or inventario_despues_de_rechazo.size() != CatalogoObjetosScript.CAPACIDAD_RANURAS:
		push_error("Error: el servidor debio rechazar el objeto nuevo sin alterar el inventario lleno.")
		servidor.free()
		quit(1)
		return

	servidor.inventarios[id_jugador] = {"colmillo_lobo": 20}
	servidor._agregar_objeto_inventario(id_jugador, "colmillo_lobo", 1)
	var inventario_despues_de_pila_llena: Dictionary = servidor.inventarios.get(id_jugador, {})
	if int(inventario_despues_de_pila_llena.get("colmillo_lobo", 0)) != 20:
		push_error("Error: el servidor no debio permitir superar el maximo de la pila.")
		servidor.free()
		quit(1)
		return

	servidor.inventarios[id_jugador] = botin.duplicate(true)

	# 5.2 La tienda valida distancia, saldo, objeto e inventario antes de cobrar.
	if servidor._normalizar_oro(-15) != 0 or servidor._normalizar_oro("inválido") != 0 or servidor._normalizar_oro(1000000000) != servidor.ORO_MAXIMO:
		push_error("Error: el oro guardado no se normalizó dentro de sus límites.")
		servidor.free()
		quit(1)
		return
	servidor.jugadores[id_jugador]["x"] = 25.0
	servidor.jugadores[id_jugador]["z"] = 0.0
	servidor.oro_jugadores[id_jugador] = 40
	var compra_lejos: Dictionary = servidor._procesar_compra_tienda(id_jugador, {"item_id": "pocion_curativa"})
	if str(compra_lejos.get("reason", "")) != "shop_out_of_range" or int(servidor.oro_jugadores[id_jugador]) != 40:
		push_error("Error: una compra fuera de rango no debió cobrar oro.")
		servidor.free()
		quit(1)
		return
	servidor.jugadores[id_jugador]["x"] = 3.0
	servidor.jugadores[id_jugador]["z"] = 0.0
	servidor.oro_jugadores[id_jugador] = 0
	var compra_sin_oro: Dictionary = servidor._procesar_compra_tienda(id_jugador, {"item_id": "pocion_curativa"})
	if str(compra_sin_oro.get("reason", "")) != "insufficient_gold" or servidor._datos_inventario(id_jugador).has("pocion_curativa"):
		push_error("Error: una compra sin saldo debió rechazarse sin entregar el objeto.")
		servidor.free()
		quit(1)
		return
	servidor.oro_jugadores[id_jugador] = 40
	var compra_correcta: Dictionary = servidor._procesar_compra_tienda(id_jugador, {"item_id": "pocion_curativa"})
	if not bool(compra_correcta.get("success", false)) or int(servidor._datos_oro(id_jugador)) != 20 or int(servidor._datos_inventario(id_jugador).get("pocion_curativa", 0)) != 1:
		push_error("Error: comprar una poción debió entregar una unidad y cobrar 20 de oro.")
		servidor.free()
		quit(1)
		return
	servidor.inventarios[id_jugador]["pocion_curativa"] = 10
	var compra_pila_llena: Dictionary = servidor._procesar_compra_tienda(id_jugador, {"item_id": "pocion_curativa"})
	if str(compra_pila_llena.get("reason", "")) != "stack_full" or servidor._datos_oro(id_jugador) != 20:
		push_error("Error: una pila llena debió rechazar la compra sin cobrar.")
		servidor.free()
		quit(1)
		return
	var compra_objeto_no_vendido: Dictionary = servidor._procesar_compra_tienda(id_jugador, {"item_id": "colmillo_lobo"})
	if str(compra_objeto_no_vendido.get("reason", "")) != "not_sold" or servidor._datos_oro(id_jugador) != 20:
		push_error("Error: la tienda debió rechazar objetos que no vende.")
		servidor.free()
		quit(1)
		return
	servidor.inventarios[id_jugador] = botin.duplicate(true)
	servidor.oro_jugadores[id_jugador] = 0
	servidor.jugadores[id_jugador]["x"] = -3.0
	servidor.jugadores[id_jugador]["z"] = 1.0
	print("OK: la tienda comprueba distancia, saldo, mercancía y límite de pila antes de cobrar.")
	print("OK: 40 de oro compran una poción y el saldo queda en 20.")
	print("OK: Inventario permite apilar un objeto existente sin ranuras libres.")
	print("OK: Inventario lleno rechaza objetos nuevos sin alterar su contenido.")
	print("OK: Inventario rechaza superar el maximo de una pila.")
	# El caso anterior dejó al lobo muerto; restablecerlo aquí aísla esta prueba.
	servidor.entidades[3]["activo"] = true
	servidor.entidades[3]["estado"] = "patrullando"
	servidor.entidades[3]["hp"] = 60
	# 5.2 Daño enemigo, muerte y reaparición del jugador
	servidor.salud_jugadores[id_jugador] = {
		"hp": 100,
		"hp_max": 100,
		"muerto": false
	}
	servidor.datos_spawn_jugadores[id_jugador] = Vector3(-3.0, 0.0, 1.0)
	servidor.entidades[3]["x"] = -3.0
	servidor.entidades[3]["y"] = 0.0
	servidor.entidades[3]["z"] = 1.0
	servidor.tiempo_ataque_lobo = 0.0
	servidor._actualizar_ataques_enemigos(0.0)
	var salud_tras_primer_golpe: Dictionary = servidor.salud_jugadores[id_jugador]
	if int(salud_tras_primer_golpe.get("hp", 0)) != 90:
		push_error("Error: el ataque del lobo debio restar 10 puntos de vida.")
		servidor.free()
		quit(1)
		return

	servidor._actualizar_ataques_enemigos(0.0)
	if int(servidor.salud_jugadores[id_jugador].get("hp", 0)) != 90:
		push_error("Error: el lobo no debio superar su tiempo de recarga.")
		servidor.free()
		quit(1)
		return

	servidor.salud_jugadores[id_jugador]["hp"] = 10
	servidor.tiempo_ataque_lobo = 0.0
	servidor._actualizar_ataques_enemigos(0.0)
	var salud_tras_golpe_letal: Dictionary = servidor.salud_jugadores[id_jugador]
	if int(salud_tras_golpe_letal.get("hp", 1)) != 0 or not bool(salud_tras_golpe_letal.get("muerto", false)):
		push_error("Error: el golpe letal del lobo debio derrotar al jugador.")
		servidor.free()
		quit(1)
		return
	if not servidor.temporizadores_respawn_jugadores.has(id_jugador):
		push_error("Error: el servidor debio programar la reaparicion del jugador.")
		servidor.free()
		quit(1)
		return

	ultimo_resultado.clear()
	servidor._procesar_ataque(id_jugador, {"target_id": 3})
	if ultimo_resultado.get("success", true) != false or ultimo_resultado.get("reason", "") != "player_dead":
		push_error("Error: un jugador derrotado no debe poder atacar.")
		servidor.free()
		quit(1)
		return

	servidor._actualizar_respawn_jugadores(servidor.TIEMPO_RESPAWN_JUGADOR + 0.5)
	var salud_reaparecida: Dictionary = servidor.salud_jugadores[id_jugador]
	var jugador_reaparecido: Dictionary = servidor.jugadores[id_jugador]
	if int(salud_reaparecida.get("hp", 0)) != 100 or bool(salud_reaparecida.get("muerto", true)):
		push_error("Error: el jugador debio reaparecer con vida completa.")
		servidor.free()
		quit(1)
		return
	if absf(float(jugador_reaparecido.get("x", 999.0)) + 3.0) > 0.01 or absf(float(jugador_reaparecido.get("z", 999.0)) - 1.0) > 0.01:
		push_error("Error: el jugador debio reaparecer en su posicion inicial.")
		servidor.free()
		quit(1)
		return
	print("OK: El lobo daña al jugador y respeta su recarga.")
	print("OK: Muerte del jugador bloquea ataques y programa respawn.")
	print("OK: Respawn del jugador restaura vida y posición inicial.")

	# El jabalí también ataca de forma autoritativa y conserva su propio cooldown.
	servidor.entidades[3]["activo"] = false
	servidor.entidades[3]["estado"] = "muerto"
	servidor.entidades[4]["activo"] = true
	servidor.entidades[4]["estado"] = "patrullando"
	servidor.entidades[4]["x"] = float(servidor.jugadores[id_jugador]["x"])
	servidor.entidades[4]["y"] = float(servidor.jugadores[id_jugador]["y"])
	servidor.entidades[4]["z"] = float(servidor.jugadores[id_jugador]["z"])
	servidor.salud_jugadores[id_jugador]["hp"] = 100
	servidor.proteccion_respawn_jugadores.erase(id_jugador)
	servidor.tiempo_ataque_jabali = 0.0
	servidor._actualizar_ataques_enemigos(0.0)
	if int(servidor.salud_jugadores[id_jugador].get("hp", 0)) != 86:
		push_error("Error: el jabalí debio infligir 14 puntos de daño.")
		servidor.free()
		quit(1)
		return
	servidor._actualizar_ataques_enemigos(0.0)
	if int(servidor.salud_jugadores[id_jugador].get("hp", 0)) != 86:
		push_error("Error: el jabalí debio respetar su recarga independiente.")
		servidor.free()
		quit(1)
		return
	print("OK: el jabalí inflige 14 de daño y respeta su recarga propia.")
	servidor.salud_jugadores[id_jugador]["hp"] = 100

	# Restablecer este estado al terminar la prueba de daño al jugador.
	servidor.entidades[3]["activo"] = false
	servidor.entidades[3]["estado"] = "muerto"
	servidor.entidades[3]["hp"] = 0
	# 6. Ataque a objetivo ya muerto
	ultimo_resultado.clear()
	servidor.tiempos_ultimo_ataque[id_jugador] = -100.0
	servidor._procesar_ataque(id_jugador, {"target_id": 3})
	if ultimo_resultado.get("success", true) != false or ultimo_resultado.get("reason", "") != "target_dead":
		push_error("Error: atacar a un muerto debio fallar con target_dead.")
		servidor.free()
		quit(1)
		return

	# 7. Reaparición autoritativa (respawn)
	if not servidor.temporizadores_respawn.has(3):
		push_error("Error: debio registrarse temporizador de respawn para la entidad 3.")
		servidor.free()
		quit(1)
		return

	servidor._actualizar_respawn(servidor.TIEMPO_RESPAWN + 0.5)
	if servidor.entidades[3]["activo"] != true or servidor.entidades[3]["estado"] != "patrullando" or servidor.entidades[3]["hp"] != 60:
		push_error("Error: la entidad 3 debio reaparecer activa, patrullando y con 60 HP.")
		servidor.free()
		quit(1)
		return

	# 8. Misión de caza aceptada con el NPC y completada con tres lobos
	servidor.misiones_jugadores[id_jugador] = servidor._mision_inicial()
	servidor.jugadores[id_jugador]["x"] = 50.0
	servidor.jugadores[id_jugador]["z"] = 50.0
	servidor._procesar_interaccion(id_jugador, {"target_id": 2})
	if str(servidor.misiones_jugadores[id_jugador].get("estado", "")) != "disponible":
		push_error("Error: el NPC no debio aceptar interaccion fuera de rango.")
		servidor.free()
		quit(1)
		return

	servidor.jugadores[id_jugador]["x"] = 3.0
	servidor.jugadores[id_jugador]["z"] = 2.0
	servidor._procesar_interaccion(id_jugador, {"target_id": 2})
	if str(servidor.misiones_jugadores[id_jugador].get("estado", "")) != "activa":
		push_error("Error: hablar con el NPC en rango debio activar la misión.")
		servidor.free()
		quit(1)
		return

	for baja in range(3):
		servidor.entidades[3]["activo"] = true
		servidor.entidades[3]["estado"] = "patrullando"
		servidor.entidades[3]["hp"] = 15
		servidor.entidades[3]["x"] = 3.0
		servidor.entidades[3]["y"] = float(servidor.jugadores[id_jugador]["y"])
		servidor.entidades[3]["z"] = 2.0
		servidor.tiempos_ultimo_ataque[id_jugador] = -100.0
		ultimo_resultado.clear()
		servidor._procesar_ataque(id_jugador, {"target_id": 3})
		if not bool(ultimo_resultado.get("success", false)):
			push_error("Error: cada baja de la misión debio completar el ataque al lobo.")
			servidor.free()
			quit(1)
			return
		var mision_actual: Dictionary = servidor.misiones_jugadores[id_jugador]
		if int(mision_actual.get("lobos", 0)) != baja + 1:
			push_error("Error: el contador de lobos de la misión no avanzó correctamente.")
			servidor.free()
			quit(1)
			return
		if baja < 2:
			servidor._actualizar_respawn(servidor.TIEMPO_RESPAWN + 0.5)

	var mision_final: Dictionary = servidor.misiones_jugadores[id_jugador]
	var progreso_final: Dictionary = servidor.progresion_jugadores[id_jugador]
	if str(mision_final.get("estado", "")) != "completada":
		push_error("Error: la misión debio completarse tras tres bajas.")
		servidor.free()
		quit(1)
		return
	if int(progreso_final.get("level", 1)) != 2 or int(progreso_final.get("xp", 0)) != 50:
		push_error("Error: la misión debio otorgar 50 XP además de 25 XP por lobo.")
		servidor.free()
		quit(1)
		return
	if servidor._datos_oro(id_jugador) != servidor.ORO_RECOMPENSA_CAZA_LOBOS:
		push_error("Error: completar la primera misión debió otorgar 30 de oro una sola vez.")
		servidor.free()
		quit(1)
		return
	if int(ultimo_resultado.get("xp_gained", 0)) != 75:
		push_error("Error: el ataque de finalización debio informar los 75 XP obtenidos.")
		servidor.free()
		quit(1)
		return
	print("OK: interacción con NPC valida rango y acepta la misión.")
	print("OK: tres bajas de lobo completan la misión y otorgan 50 XP de recompensa.")
	var inventario_mision: Dictionary = servidor.inventarios[id_jugador]
	if int(inventario_mision.get("pocion_curativa", 0)) != 2:
		push_error("Error: completar la misión debio entregar dos pociones.")
		servidor.free()
		quit(1)
		return

	servidor.salud_jugadores[id_jugador] = {"hp": 90, "hp_max": 100, "muerto": false}
	var pocion_parcial: Dictionary = servidor._procesar_uso_objeto(id_jugador, {"item_id": "pocion_curativa"})
	if not bool(pocion_parcial.get("success", false)) or int(pocion_parcial.get("healed", 0)) != 10:
		push_error("Error: la poción debio limitar la curación a la vida faltante.")
		servidor.free()
		quit(1)
		return
	if int(servidor.salud_jugadores[id_jugador].get("hp", 0)) != 100 or int(servidor.inventarios[id_jugador].get("pocion_curativa", 0)) != 1:
		push_error("Error: la poción debio restaurar vida y consumir una unidad.")
		servidor.free()
		quit(1)
		return

	var pocion_vida_llena: Dictionary = servidor._procesar_uso_objeto(id_jugador, {"item_id": "pocion_curativa"})
	if bool(pocion_vida_llena.get("success", true)) or str(pocion_vida_llena.get("reason", "")) != "health_full":
		push_error("Error: no se debe consumir una poción cuando la vida está completa.")
		servidor.free()
		quit(1)
		return
	if int(servidor.inventarios[id_jugador].get("pocion_curativa", 0)) != 1:
		push_error("Error: el rechazo por vida llena no debio consumir la poción.")
		servidor.free()
		quit(1)
		return

	servidor.salud_jugadores[id_jugador]["hp"] = 40
	var pocion_usada: Dictionary = servidor._procesar_uso_objeto(id_jugador, {"item_id": "pocion_curativa"})
	if not bool(pocion_usada.get("success", false)) or int(pocion_usada.get("healed", 0)) != 35:
		push_error("Error: la poción debio curar 35 puntos cuando había suficiente daño.")
		servidor.free()
		quit(1)
		return
	if int(servidor.salud_jugadores[id_jugador].get("hp", 0)) != 75 or servidor.inventarios[id_jugador].has("pocion_curativa"):
		push_error("Error: usar la segunda poción debio restaurar 35 HP y agotar la pila.")
		servidor.free()
		quit(1)
		return
	print("OK: la misión entrega pociones que curan sin sobrepasar vida máxima y se consumen.")
	var equipo_resultado: Dictionary = servidor._procesar_equipar_objeto(id_jugador, {"item_id": "espada_del_habitante"})
	if not bool(equipo_resultado.get("success", false)) or str(servidor._datos_equipamiento(id_jugador).get("arma", "")) != "espada_del_habitante":
		push_error("Error: la espada en inventario debio equiparse.")
		servidor.free()
		quit(1)
		return
	if servidor._bono_danio_equipado(id_jugador) != 5:
		push_error("Error: la espada debio añadir cinco puntos de daño.")
		servidor.free()
		quit(1)
		return

	servidor.entidades[3]["activo"] = true
	servidor.entidades[3]["estado"] = "patrullando"
	servidor.entidades[3]["hp"] = 60
	servidor.entidades[3]["x"] = float(servidor.jugadores[id_jugador]["x"])
	servidor.entidades[3]["y"] = float(servidor.jugadores[id_jugador]["y"])
	servidor.entidades[3]["z"] = float(servidor.jugadores[id_jugador]["z"])
	servidor.tiempos_ultimo_ataque[id_jugador] = -100.0
	ultimo_resultado.clear()
	servidor._procesar_ataque(id_jugador, {"target_id": 3})
	if int(ultimo_resultado.get("damage", 0)) != 22:
		push_error("Error: el ataque de nivel 2 con espada debio infligir 22 de daño.")
		servidor.free()
		quit(1)
		return
	print("OK: la espada equipada aporta +5 y el servidor aplica 22 de daño a nivel 2.")



	if int(inventario_mision.get("espada_del_habitante", 0)) != 1:
		push_error("Error: completar la misión debio entregar la espada del Habitante.")
		servidor.free()
		quit(1)
		return

	# 9. Segunda misión: reunir y entregar pieles de lobo al Habitante.
	servidor._procesar_interaccion(id_jugador, {"target_id": 2})
	var mision_entrega: Dictionary = servidor.misiones_jugadores[id_jugador]
	if str(mision_entrega.get("id", "")) != "entrega_pieles" or str(mision_entrega.get("estado", "")) != "activa":
		push_error("Error: hablar tras completar la caza debio iniciar la entrega de pieles.")
		servidor.free()
		quit(1)
		return
	if int(mision_entrega.get("pieles", 0)) != 3:
		push_error("Error: la misión debio contar las pieles que el jugador ya llevaba.")
		servidor.free()
		quit(1)
		return

	servidor.inventarios[id_jugador]["piel_lobo"] = 2
	servidor._procesar_interaccion(id_jugador, {"target_id": 2})
	var mision_sin_materiales: Dictionary = servidor.misiones_jugadores[id_jugador]
	if str(mision_sin_materiales.get("estado", "")) != "activa" or int(mision_sin_materiales.get("pieles", -1)) != 2:
		push_error("Error: sin tres pieles la misión debio continuar activa y reflejar 2/3.")
		servidor.free()
		quit(1)
		return
	if int(servidor.inventarios[id_jugador].get("piel_lobo", 0)) != 2:
		push_error("Error: el intento de entrega incompleta no debio consumir pieles.")
		servidor.free()
		quit(1)
		return

	servidor._agregar_objeto_inventario(id_jugador, "piel_lobo", 3)
	if int(servidor.misiones_jugadores[id_jugador].get("pieles", 0)) != 3:
		push_error("Error: el botin nuevo debio avanzar el objetivo de entrega.")
		servidor.free()
		quit(1)
		return
	servidor._procesar_interaccion(id_jugador, {"target_id": 2})
	var mision_entregada: Dictionary = servidor.misiones_jugadores[id_jugador]
	if str(mision_entregada.get("estado", "")) != "completada" or int(mision_entregada.get("pieles", 0)) != 3:
		push_error("Error: entregar tres pieles debio completar la misión.")
		servidor.free()
		quit(1)
		return
	if int(servidor.inventarios[id_jugador].get("piel_lobo", 0)) != 2:
		push_error("Error: completar la entrega debio consumir solo tres pieles y preservar las restantes.")
		servidor.free()
		quit(1)
		return
	var progreso_tras_entrega: Dictionary = servidor.progresion_jugadores[id_jugador]
	if int(progreso_tras_entrega.get("level", 0)) != 3 or int(progreso_tras_entrega.get("xp", -1)) != 25:
		push_error("Error: completar la entrega debio otorgar 75 XP y conservar el excedente de nivel.")
		servidor.free()
		quit(1)
		return
	var oro_esperado_pieles: int = servidor.ORO_RECOMPENSA_CAZA_LOBOS + servidor.ORO_RECOMPENSA_ENTREGA_PIELES
	if servidor._datos_oro(id_jugador) != oro_esperado_pieles:
		push_error("Error: entregar pieles debio sumar exactamente 15 de oro.")
		servidor.free()
		quit(1)
		return
	print("OK: segunda misión cuenta materiales existentes, rechaza entregas incompletas, actualiza el botín y consume solo tres pieles.")

	servidor.entidades[3]["activo"] = true
	servidor.entidades[3]["estado"] = "patrullando"
	servidor.entidades[3]["hp"] = 60
	servidor.entidades[3]["x"] = float(servidor.jugadores[id_jugador]["x"])
	servidor.entidades[3]["y"] = float(servidor.jugadores[id_jugador]["y"])
	servidor.entidades[3]["z"] = float(servidor.jugadores[id_jugador]["z"])
	servidor.tiempos_ultimo_ataque[id_jugador] = -100.0
	ultimo_resultado.clear()
	servidor._procesar_ataque(id_jugador, {"target_id": 3, "skill_id": "habilidad_inexistente"})
	if bool(ultimo_resultado.get("success", true)) or str(ultimo_resultado.get("reason", "")) != "invalid_skill":
		push_error("Error: el servidor debio rechazar una habilidad desconocida.")
		servidor.free()
		quit(1)
		return
	ultimo_resultado.clear()
	servidor._procesar_ataque(id_jugador, {"target_id": 3, "skill_id": "golpe_pesado"})
	if not bool(ultimo_resultado.get("success", false)) or str(ultimo_resultado.get("skill_id", "")) != "golpe_pesado" or int(ultimo_resultado.get("damage", 0)) != 48:
		push_error("Error: a nivel 3, con espada, el golpe pesado debio infligir 48 de daño validado por servidor.")
		servidor.free()
		quit(1)
		return
	servidor.tiempos_ultimo_ataque[id_jugador] = -100.0
	ultimo_resultado.clear()
	servidor._procesar_ataque(id_jugador, {"target_id": 3, "skill_id": "golpe_pesado"})
	if bool(ultimo_resultado.get("success", true)) or str(ultimo_resultado.get("reason", "")) != "skill_on_cooldown" or float(ultimo_resultado.get("cooldown_restante", 0.0)) <= 5.8:
		push_error("Error: el golpe pesado debio conservar su recarga individual de seis segundos.")
		servidor.free()
		quit(1)
		return
	print("OK: golpe pesado duplica el daño con equipo/nivel y su recarga de 6 s es autoritativa.")

	print("OK: Validacion de objetivo invalido correcta.")
	print("OK: Validacion de rango melee (out_of_range) correcta.")
	print("OK: Aplicacion de danio y reduccion de HP correcta.")
	print("OK: Tiempo de recarga (on_cooldown) verificado.")
	print("OK: Transicion a estado muerto y activo=false comprobada.")
	print("OK: Botin de colmillo/piel y 25 XP entregados al atacante final.")
	print("OK: Rechazo de ataque a entidad muerta (target_dead) comprobado.")
	print("OK: Reaparicion autoritativa (respawn) con HP completo comprobada.")

	# 10. Tercera misión: entregar carne de jabalí al Habitante.
	servidor._agregar_objeto_inventario(id_jugador, "carne_jabali", 1)
	servidor._procesar_interaccion(id_jugador, {"target_id": 2})
	var mision_carne: Dictionary = servidor._datos_mision(id_jugador)
	if str(mision_carne.get("id", "")) != "entrega_carne_jabali" or str(mision_carne.get("estado", "")) != "activa" or int(mision_carne.get("carne", 0)) != 1:
		push_error("Error: la tercera misión debió activarse contando la carne existente.")
		servidor.free()
		quit(1)
		return
	servidor._procesar_interaccion(id_jugador, {"target_id": 2})
	if int(servidor._datos_inventario(id_jugador).get("carne_jabali", 0)) != 1 or str(servidor._datos_mision(id_jugador).get("estado", "")) != "activa":
		push_error("Error: intentar entregar carne insuficiente no debió consumirla ni completar la misión.")
		servidor.free()
		quit(1)
		return
	servidor._agregar_objeto_inventario(id_jugador, "carne_jabali", 3)
	if int(servidor._datos_mision(id_jugador).get("carne", 0)) != 3:
		push_error("Error: la misión de carne no contó el botín recogido.")
		servidor.free()
		quit(1)
		return
	var progreso_antes: Dictionary = servidor._datos_progresion(id_jugador)
	var xp_total_antes: int = int(progreso_antes.get("level", 1)) * servidor.XP_PARA_SUBIR_NIVEL + int(progreso_antes.get("xp", 0))
	servidor._procesar_interaccion(id_jugador, {"target_id": 2})
	var mision_carne_completa: Dictionary = servidor._datos_mision(id_jugador)
	var progreso_despues: Dictionary = servidor._datos_progresion(id_jugador)
	var xp_total_despues: int = int(progreso_despues.get("level", 1)) * servidor.XP_PARA_SUBIR_NIVEL + int(progreso_despues.get("xp", 0))
	if str(mision_carne_completa.get("estado", "")) != "completada" or int(servidor._datos_inventario(id_jugador).get("carne_jabali", 0)) != 1 or xp_total_despues - xp_total_antes != servidor.XP_RECOMPENSA_ENTREGA_CARNE:
		push_error("Error: la entrega válida debió consumir solo tres carnes y otorgar 100 XP.")
		servidor.free()
		quit(1)
		return
	var oro_esperado_carne: int = oro_esperado_pieles + servidor.ORO_RECOMPENSA_ENTREGA_CARNE
	if servidor._datos_oro(id_jugador) != oro_esperado_carne:
		push_error("Error: entregar carne de jabalí debio sumar exactamente 25 de oro.")
		servidor.free()
		quit(1)
		return
	var mision_carne_guardada: Dictionary = servidor._normalizar_mision(mision_carne_completa)
	if str(mision_carne_guardada.get("id", "")) != "entrega_carne_jabali" or str(mision_carne_guardada.get("estado", "")) != "completada" or int(mision_carne_guardada.get("carne", 0)) != 3:
		push_error("Error: la tercera misión no se normalizó correctamente para guardar/cargar.")
		servidor.free()
		quit(1)
		return
	print("OK: tercera misión cuenta materiales, valida faltantes, conserva sobrante, paga 100 XP y normaliza el estado guardable.")

	var ruta_guardado_prueba := "C:/Users/Bruker/Documents/Codex/classicrpg_prueba_guardado_%d.json" % Time.get_ticks_usec()
	servidor.ruta_guardado_local = ruta_guardado_prueba
	servidor.jugadores[id_jugador]["x"] = -7.25
	servidor.jugadores[id_jugador]["y"] = 1.5
	servidor.jugadores[id_jugador]["z"] = 11.75
	servidor.jugadores[id_jugador]["yaw"] = 1.25
	servidor.modo_individual = false
	servidor._guardar_partida_local(id_jugador)
	var errores_persistencia: Array[String] = []
	if FileAccess.file_exists(ruta_guardado_prueba):
		errores_persistencia.append("el servidor externo escribió una partida local")

	servidor.oro_jugadores[id_jugador] = 77
	servidor.modo_individual = true
	servidor._guardar_partida_local(id_jugador)
	if not FileAccess.file_exists(ruta_guardado_prueba):
		errores_persistencia.append("el modo individual no creó el archivo de guardado")
	else:
		servidor._al_conectar(11)
		var inventario_restaurado: Dictionary = servidor.inventarios.get(11, {})
		var progresion_restaurada: Dictionary = servidor.progresion_jugadores.get(11, {})
		var mision_restaurada: Dictionary = servidor.misiones_jugadores.get(11, {})
		var salud_restaurada: Dictionary = servidor.salud_jugadores.get(11, {})
		var equipo_restaurado: Dictionary = servidor.equipamiento_jugadores.get(11, {})
		var jugador_restaurado: Dictionary = servidor.jugadores.get(11, {})
		if servidor._datos_oro(11) != 77:
			errores_persistencia.append("el saldo de oro no se restauró")
		if inventario_restaurado != servidor._datos_inventario(id_jugador):
			errores_persistencia.append("el inventario no se restauró igual")
		if int(progresion_restaurada.get("level", 0)) != 4 or int(progresion_restaurada.get("xp", -1)) != 25:
			errores_persistencia.append("el nivel y la experiencia no se restauraron")
		if str(mision_restaurada.get("id", "")) != "entrega_carne_jabali" or str(mision_restaurada.get("estado", "")) != "completada" or int(mision_restaurada.get("carne", 0)) != 3:
			errores_persistencia.append("el estado y progreso de la segunda misión no se restauraron")
		if int(salud_restaurada.get("hp", 0)) != 75:
			errores_persistencia.append("la salud no se restauró")
		if str(equipo_restaurado.get("arma", "")) != "espada_del_habitante":
			errores_persistencia.append("el arma equipada no se restauró")
		if not jugador_restaurado.has("x") or absf(float(jugador_restaurado.get("x", 0.0)) + 7.25) > 0.001 or absf(float(jugador_restaurado.get("z", 0.0)) - 11.75) > 0.001 or absf(float(jugador_restaurado.get("yaw", 0.0)) - 1.25) > 0.001:
			errores_persistencia.append("la posición y orientación no se restauraron")

	if _escribir_guardado_prueba(ruta_guardado_prueba, "{json-corrupto"):
		if not servidor._leer_partida_local().is_empty():
			errores_persistencia.append("un archivo JSON corrupto no se descartó con seguridad")
	else:
		errores_persistencia.append("no se pudo preparar el archivo JSON corrupto de prueba")

	if _escribir_guardado_prueba(ruta_guardado_prueba, JSON.stringify({"version": 2})):
		if not servidor._leer_partida_local().is_empty():
			errores_persistencia.append("una versión de guardado desconocida no se descartó")
	else:
		errores_persistencia.append("no se pudo preparar la versión desconocida de prueba")

	var datos_malformados := {
		"version": 1,
		"inventory": {"pocion_curativa": [999], "piel_lobo": 999},
		"progression": {"level": {"nivel": 5}, "xp": [75]},
		"health": {"hp": [100]},
		"quest": {"id": "entrega_pieles", "estado": "activa", "pieles": {"cantidad": 3}},
		"equipment": {"arma": "objeto_inexistente"},
		"gold": "mucho",
		"position": {"x": [0], "y": 1, "z": 2, "yaw": [0]}
	}
	if _escribir_guardado_prueba(ruta_guardado_prueba, JSON.stringify(datos_malformados)):
		var cargado_malformado: Dictionary = servidor._leer_partida_local()
		var inventario_seguro: Dictionary = servidor._normalizar_inventario(cargado_malformado.get("inventory", {}))
		var progreso_seguro: Dictionary = servidor._normalizar_progresion(cargado_malformado.get("progression", {}))
		var salud_segura: Dictionary = servidor._normalizar_salud(cargado_malformado.get("health", {}))
		var mision_segura: Dictionary = servidor._normalizar_mision(cargado_malformado.get("quest", {}))
		var equipo_seguro: Dictionary = servidor._normalizar_equipamiento(cargado_malformado.get("equipment", {}), inventario_seguro)
		if inventario_seguro.has("pocion_curativa") or int(inventario_seguro.get("piel_lobo", 0)) != 10:
			errores_persistencia.append("el inventario malformado no se limitó a datos seguros")
		if int(progreso_seguro.get("level", 0)) != 1 or int(progreso_seguro.get("xp", -1)) != 0:
			errores_persistencia.append("la progresión malformada no volvió a valores seguros")
		if int(salud_segura.get("hp", 0)) != 100:
			errores_persistencia.append("la salud malformada no volvió a vida completa")
		if str(mision_segura.get("id", "")) != "entrega_pieles" or int(mision_segura.get("pieles", -1)) != 0:
			errores_persistencia.append("el contador malformado de la misión no volvió a cero")
		if not equipo_seguro.get("arma", "").is_empty():
			errores_persistencia.append("el equipo desconocido no se rechazó")
		if servidor._normalizar_oro(cargado_malformado.get("gold", 0)) != 0:
			errores_persistencia.append("el oro malformado no volvió a cero")
		if servidor._posicion_guardada_valida(cargado_malformado.get("position", {})) or servidor._yaw_guardado(cargado_malformado.get("position", {})) != 0.0:
			errores_persistencia.append("la posición/orientación malformada no se rechazó")
	else:
		errores_persistencia.append("no se pudo preparar el archivo con campos malformados")
	_borrar_guardado_prueba(ruta_guardado_prueba)
	servidor.modo_individual = false
	if not errores_persistencia.is_empty():
		for error_persistencia in errores_persistencia:
			push_error("Error de guardado/carga: " + error_persistencia)
		servidor.free()
		quit(1)
		return
	print("OK: el modo individual guarda y restaura posición, orientación, vida, inventario, progresión, misión y equipo.")
	print("OK: el servidor externo no escribe guardados locales.")
	print("OK: JSON corrupto, versión desconocida y campos malformados se recuperan con valores seguros.")

	# 11. Descartar objetos valida propiedad/estado, actualiza misiones y desarma equipo eliminado.
	servidor.modo_individual = false
	var mision_previa_descartar: Dictionary = servidor._datos_mision(id_jugador)
	servidor.salud_jugadores[id_jugador] = {"hp": 100, "hp_max": 100, "muerto": false}
	servidor.inventarios[id_jugador] = {"gelatina_limo": 4, "espada_del_habitante": 1}
	servidor.misiones_jugadores[id_jugador] = {
		"id": "entrega_gelatina_limo",
		"estado": "activa",
		"gelatina": 3
	}
	servidor.equipamiento_jugadores[id_jugador] = {"arma": "espada_del_habitante"}
	var resultado_descartar_gelatina: Dictionary = servidor._procesar_descartar_objeto(
		id_jugador,
		{"item_id": "gelatina_limo"}
	)
	if not bool(resultado_descartar_gelatina.get("success", false)) or int(servidor._datos_inventario(id_jugador).get("gelatina_limo", 0)) != 3 or int(servidor._datos_mision(id_jugador).get("gelatina", 0)) != 3:
		push_error("Error: descartar gelatina debió quitar una unidad y mantener el progreso de misión sincronizado con la cantidad restante.")
		servidor.free()
		quit(1)
		return
	var resultado_descartar_espada: Dictionary = servidor._procesar_descartar_objeto(
		id_jugador,
		{"item_id": "espada_del_habitante"}
	)
	if not bool(resultado_descartar_espada.get("success", false)) or servidor._datos_inventario(id_jugador).has("espada_del_habitante") or not str(servidor._datos_equipamiento(id_jugador).get("arma", "")).is_empty():
		push_error("Error: descartar la última unidad equipada debió quitarla del inventario y desarmar al jugador.")
		servidor.free()
		quit(1)
		return
	var rechazo_no_poseido: Dictionary = servidor._procesar_descartar_objeto(id_jugador, {"item_id": "pocion_curativa"})
	var rechazo_objeto_invalido: Dictionary = servidor._procesar_descartar_objeto(id_jugador, {"item_id": "objeto_inexistente"})
	if str(rechazo_no_poseido.get("reason", "")) != "not_owned" or str(rechazo_objeto_invalido.get("reason", "")) != "invalid_item":
		push_error("Error: el servidor debió rechazar objetos no poseídos o IDs desconocidos.")
		servidor.free()
		quit(1)
		return
	servidor.salud_jugadores[id_jugador] = {"hp": 0, "hp_max": 100, "muerto": true}
	var rechazo_muerto: Dictionary = servidor._procesar_descartar_objeto(id_jugador, {"item_id": "gelatina_limo"})
	if str(rechazo_muerto.get("reason", "")) != "player_dead" or int(servidor._datos_inventario(id_jugador).get("gelatina_limo", 0)) != 3:
		push_error("Error: el servidor debió rechazar el descarte durante la muerte sin alterar el inventario.")
		servidor.free()
		quit(1)
		return
	servidor.salud_jugadores[id_jugador] = {"hp": 100, "hp_max": 100, "muerto": false}
	servidor.modo_individual = true
	servidor._guardar_partida_local(id_jugador)
	var archivo_descartar := FileAccess.open(ruta_guardado_prueba, FileAccess.READ)
	if archivo_descartar == null:
		push_error("Error: descartar objetos no persistió el inventario actualizado en modo individual.")
		servidor.modo_individual = false
		_borrar_guardado_prueba(ruta_guardado_prueba)
		servidor.free()
		quit(1)
		return
	var datos_descartar_guardados: Variant = JSON.parse_string(archivo_descartar.get_as_text())
	archivo_descartar.close()
	var inventario_descartar_guardado: Dictionary = datos_descartar_guardados.get("inventory", {}) if typeof(datos_descartar_guardados) == TYPE_DICTIONARY else {}
	var equipo_descartar_guardado: Dictionary = datos_descartar_guardados.get("equipment", {}) if typeof(datos_descartar_guardados) == TYPE_DICTIONARY else {}
	if int(inventario_descartar_guardado.get("gelatina_limo", 0)) != 3 or inventario_descartar_guardado.has("espada_del_habitante") or not str(equipo_descartar_guardado.get("arma", "")).is_empty():
		push_error("Error: el guardado no reflejó el inventario y el equipo tras descartar.")
		servidor.modo_individual = false
		_borrar_guardado_prueba(ruta_guardado_prueba)
		servidor.free()
		quit(1)
		return
	servidor.modo_individual = false
	_borrar_guardado_prueba(ruta_guardado_prueba)
	print("OK: descarte autoritativo quita una unidad, sincroniza misión, desarma equipo, rechaza casos inválidos/muertos y persiste en partida individual.")

	# La prueba de combate siguiente presupone la espada de la misión inicial equipada.
	servidor.misiones_jugadores[id_jugador] = mision_previa_descartar
	servidor.equipamiento_jugadores[id_jugador] = {"arma": "espada_del_habitante"}
	servidor.entidades[4]["activo"] = true
	servidor.entidades[4]["estado"] = "patrullando"
	servidor.entidades[4]["hp"] = 24
	servidor.inventarios[id_jugador].clear()
	servidor.entidades[4]["x"] = float(servidor.jugadores[id_jugador]["x"])
	servidor.entidades[4]["y"] = float(servidor.jugadores[id_jugador]["y"])
	servidor.entidades[4]["z"] = float(servidor.jugadores[id_jugador]["z"])
	servidor.tiempos_ultimo_ataque[id_jugador] = -100.0
	ultimo_resultado.clear()
	servidor._procesar_ataque(id_jugador, {"target_id": 4})
	var botin_jabali: Dictionary = servidor._datos_inventario(id_jugador)
	if not bool(ultimo_resultado.get("success", false)) or str(ultimo_resultado.get("target_state", "")) != "muerto" or int(ultimo_resultado.get("xp_gained", 0)) != servidor.XP_POR_JABALI:
		push_error("Error: derrotar al jabalí debio otorgar su XP y activar su respawn.")
		servidor.free()
		quit(1)
		return
	if int(botin_jabali.get("colmillo_jabali", 0)) != 1 or int(botin_jabali.get("carne_jabali", 0)) != 1:
		push_error("Error: derrotar al jabalí debio entregar colmillo y carne.")
		servidor.free()
		quit(1)
		return
	servidor._actualizar_respawn(servidor.TIEMPO_RESPAWN + 0.5)
	if not bool(servidor.entidades[4].get("activo", false)) or int(servidor.entidades[4].get("hp", 0)) != servidor.VIDA_MAXIMA_JABALI:
		push_error("Error: el jabalí debio reaparecer con vida completa.")
		servidor.free()
		quit(1)
		return
	print("OK: jabalí derrotado entrega botín/XP y reaparece con 80 HP.")

	# 11. Misión posterior: aceptar y completar la caza de tres jabalíes.
	servidor.jugadores[id_jugador]["x"] = 3.0
	servidor.jugadores[id_jugador]["z"] = 0.0
	servidor._procesar_interaccion(id_jugador, {"target_id": 2})
	var mision_caza: Dictionary = servidor._datos_mision(id_jugador)
	if str(mision_caza.get("id", "")) != "caza_jabalies" or str(mision_caza.get("estado", "")) != "activa":
		push_error("Error: entregar provisiones completadas debió habilitar la caza de jabalíes.")
		servidor.free()
		quit(1)
		return
	var xp_antes_caza := servidor._datos_progresion(id_jugador)
	var total_xp_antes_caza: int = int(xp_antes_caza.get("level", 1)) * servidor.XP_PARA_SUBIR_NIVEL + int(xp_antes_caza.get("xp", 0))
	var oro_antes_caza_jabalies: int = servidor._datos_oro(id_jugador)
	for baja in range(servidor.JABALIES_REQUERIDOS_MISION):
		servidor.entidades[4]["activo"] = true
		servidor.entidades[4]["estado"] = "patrullando"
		servidor.entidades[4]["hp"] = 1
		servidor.entidades[4]["x"] = float(servidor.jugadores[id_jugador]["x"])
		servidor.entidades[4]["y"] = float(servidor.jugadores[id_jugador]["y"])
		servidor.entidades[4]["z"] = float(servidor.jugadores[id_jugador]["z"])
		servidor.tiempos_ultimo_ataque[id_jugador] = -100.0
		servidor._procesar_ataque(id_jugador, {"target_id": 4})
	var mision_caza_completa: Dictionary = servidor._datos_mision(id_jugador)
	var xp_despues_caza := servidor._datos_progresion(id_jugador)
	var total_xp_despues_caza: int = int(xp_despues_caza.get("level", 1)) * servidor.XP_PARA_SUBIR_NIVEL + int(xp_despues_caza.get("xp", 0))
	if str(mision_caza_completa.get("estado", "")) != "completada" or int(mision_caza_completa.get("jabalies", 0)) != servidor.JABALIES_REQUERIDOS_MISION or total_xp_despues_caza - total_xp_antes_caza != servidor.XP_POR_JABALI * servidor.JABALIES_REQUERIDOS_MISION + servidor.XP_RECOMPENSA_CAZA_JABALI:
		push_error("Error: tres bajas de jabalí debieron completar la misión y recompensar XP de combate y misión.")
		servidor.free()
		quit(1)
		return
	var oro_esperado_caza_jabalies: int = oro_antes_caza_jabalies + servidor.ORO_RECOMPENSA_CAZA_JABALIES
	if servidor._datos_oro(id_jugador) != oro_esperado_caza_jabalies:
		push_error("Error: completar la caza de jabalíes debio sumar exactamente 30 de oro.")
		servidor.free()
		quit(1)
		return
	var mision_caza_normalizada: Dictionary = servidor._normalizar_mision(mision_caza_completa)
	if str(mision_caza_normalizada.get("id", "")) != "caza_jabalies" or str(mision_caza_normalizada.get("estado", "")) != "completada":
		push_error("Error: la misión de caza de jabalíes no se normalizó para persistencia.")
		servidor.free()
		quit(1)
		return
	servidor.inventarios[id_jugador]["pocion_curativa"] = 9
	servidor._procesar_interaccion(id_jugador, {"target_id": 2})
	if int(servidor._datos_inventario(id_jugador).get("pocion_curativa", 0)) != 9 or bool(servidor._datos_mision(id_jugador).get("recompensa_reclamada", false)):
		push_error("Error: la recompensa no debe perderse si la pila de pociones no admite dos unidades.")
		servidor.free()
		quit(1)
		return
	servidor.inventarios[id_jugador]["pocion_curativa"] = 8
	servidor._procesar_interaccion(id_jugador, {"target_id": 2})
	var pociones_recompensa := int(servidor._datos_inventario(id_jugador).get("pocion_curativa", 0))
	servidor._procesar_interaccion(id_jugador, {"target_id": 2})
	var mision_gelatina_inicial: Dictionary = servidor._datos_mision(id_jugador)
	if pociones_recompensa != 10 or int(servidor._datos_inventario(id_jugador).get("pocion_curativa", 0)) != 10 or str(mision_gelatina_inicial.get("id", "")) != "entrega_gelatina_limo" or str(mision_gelatina_inicial.get("estado", "")) != "activa":
		push_error("Error: la recompensa de misión debía entregar dos pociones una sola vez.")
		servidor.free()
		quit(1)
		return
	print("OK: caza de jabalíes entrega las dos pociones una sola vez y desbloquea la misión del limo.")

	# Tercera criatura de la zona: ataque propio, botín, experiencia y respawn.
	var estado_jugador_limo: Dictionary = servidor.jugadores[id_jugador]
	servidor.entidades[3]["activo"] = false
	servidor.entidades[4]["activo"] = false
	servidor.entidades[5]["activo"] = true
	servidor.entidades[5]["estado"] = "patrullando"
	servidor.entidades[5]["hp"] = servidor.VIDA_MAXIMA_LIMO
	servidor.entidades[5]["x"] = float(estado_jugador_limo.get("x", 0.0))
	servidor.entidades[5]["y"] = float(estado_jugador_limo.get("y", 0.0))
	servidor.entidades[5]["z"] = float(estado_jugador_limo.get("z", 0.0))
	servidor.salud_jugadores[id_jugador] = {"hp": 100, "hp_max": 100, "muerto": false}
	servidor.proteccion_respawn_jugadores.erase(id_jugador)
	servidor.tiempo_ataque_limo = 0.0
	servidor._actualizar_ataques_enemigos(0.0)
	if int(servidor.salud_jugadores[id_jugador].get("hp", 0)) != 100 - servidor.DANIO_LIMO:
		push_error("Error: el limo debio infligir su daño básico al jugador.")
		servidor.free()
		quit(1)
		return
	servidor._actualizar_ataques_enemigos(0.0)
	if int(servidor.salud_jugadores[id_jugador].get("hp", 0)) != 100 - servidor.DANIO_LIMO:
		push_error("Error: el limo debio respetar su recarga independiente.")
		servidor.free()
		quit(1)
		return
	var inventario_antes_limo: Dictionary = servidor._datos_inventario(id_jugador)
	var progresion_antes_limo: Dictionary = servidor._datos_progresion(id_jugador)
	var xp_total_antes_limo: int = int(progresion_antes_limo.get("level", 1)) * servidor.XP_PARA_SUBIR_NIVEL + int(progresion_antes_limo.get("xp", 0))
	servidor.entidades[5]["hp"] = 1
	servidor.tiempos_ultimo_ataque[id_jugador] = -100.0
	ultimo_resultado.clear()
	servidor._procesar_ataque(id_jugador, {"target_id": 5})
	var progresion_despues_limo: Dictionary = servidor._datos_progresion(id_jugador)
	var xp_total_despues_limo: int = int(progresion_despues_limo.get("level", 1)) * servidor.XP_PARA_SUBIR_NIVEL + int(progresion_despues_limo.get("xp", 0))
	if not bool(ultimo_resultado.get("success", false)) or int(ultimo_resultado.get("xp_gained", 0)) != servidor.XP_POR_LIMO or xp_total_despues_limo - xp_total_antes_limo != servidor.XP_POR_LIMO:
		push_error("Error: derrotar al limo debio otorgar su XP configurada.")
		servidor.free()
		quit(1)
		return
	if int(servidor._datos_inventario(id_jugador).get("gelatina_limo", 0)) != int(inventario_antes_limo.get("gelatina_limo", 0)) + 1 or not servidor.temporizadores_respawn.has(5):
		push_error("Error: derrotar al limo debio entregar gelatina y programar respawn.")
		servidor.free()
		quit(1)
		return
	servidor._actualizar_respawn(servidor.TIEMPO_RESPAWN + 0.5)
	if not bool(servidor.entidades[5].get("activo", false)) or int(servidor.entidades[5].get("hp", 0)) != servidor.VIDA_MAXIMA_LIMO:
		push_error("Error: el limo debio reaparecer activo con vida completa.")
		servidor.free()
		quit(1)
		return
	print("OK: el limo ataca con recarga propia; al derrotarlo da gelatina y XP y reaparece con vida completa.")
	if int(servidor._datos_mision(id_jugador).get("gelatina", 0)) != 1:
		push_error("Error: el botín del limo debio actualizar el objetivo de entrega activo.")
		servidor.free()
		quit(1)
		return
	var mision_gelatina_normalizada: Dictionary = servidor._normalizar_mision(servidor._datos_mision(id_jugador))
	if str(mision_gelatina_normalizada.get("id", "")) != "entrega_gelatina_limo" or int(mision_gelatina_normalizada.get("gelatina", 0)) != 1:
		push_error("Error: el progreso de entrega de gelatina no se normalizó para persistencia.")
		servidor.free()
		quit(1)
		return
	servidor._procesar_interaccion(id_jugador, {"target_id": 2})
	if int(servidor._datos_inventario(id_jugador).get("gelatina_limo", 0)) != 1 or str(servidor._datos_mision(id_jugador).get("estado", "")) != "activa":
		push_error("Error: una entrega incompleta de gelatina no debio consumir el objeto ni completar la misión.")
		servidor.free()
		quit(1)
		return
	servidor._agregar_objeto_inventario(id_jugador, "gelatina_limo", 4)
	if int(servidor._datos_mision(id_jugador).get("gelatina", 0)) != servidor.GELATINA_LIMO_REQUERIDA_MISION:
		push_error("Error: el progreso de gelatina debio respetar el límite del objetivo.")
		servidor.free()
		quit(1)
		return
	var progresion_antes_entrega_limo: Dictionary = servidor._datos_progresion(id_jugador)
	var xp_antes_entrega_limo: int = int(progresion_antes_entrega_limo.get("level", 1)) * servidor.XP_PARA_SUBIR_NIVEL + int(progresion_antes_entrega_limo.get("xp", 0))
	var oro_antes_entrega_gelatina: int = servidor._datos_oro(id_jugador)
	servidor._procesar_interaccion(id_jugador, {"target_id": 2})
	var mision_gelatina_completa: Dictionary = servidor._datos_mision(id_jugador)
	var progresion_despues_entrega_limo: Dictionary = servidor._datos_progresion(id_jugador)
	var xp_despues_entrega_limo: int = int(progresion_despues_entrega_limo.get("level", 1)) * servidor.XP_PARA_SUBIR_NIVEL + int(progresion_despues_entrega_limo.get("xp", 0))
	if str(mision_gelatina_completa.get("estado", "")) != "completada" or int(mision_gelatina_completa.get("gelatina", 0)) != servidor.GELATINA_LIMO_REQUERIDA_MISION or xp_despues_entrega_limo - xp_antes_entrega_limo != servidor.XP_RECOMPENSA_ENTREGA_GELATINA:
		push_error("Error: entregar tres gelatinas debio completar la misión y otorgar 120 XP.")
		servidor.free()
		quit(1)
		return
	if int(servidor._datos_inventario(id_jugador).get("gelatina_limo", 0)) != 2:
		push_error("Error: la entrega de gelatina debio consumir solo tres unidades y conservar el sobrante.")
		servidor.free()
		quit(1)
		return
	var oro_esperado_gelatina: int = oro_antes_entrega_gelatina + servidor.ORO_RECOMPENSA_ENTREGA_GELATINA
	if servidor._datos_oro(id_jugador) != oro_esperado_gelatina:
		push_error("Error: entregar gelatinas debio sumar exactamente 35 de oro.")
		servidor.free()
		quit(1)
		return
	var mision_gelatina_guardada: Dictionary = servidor._normalizar_mision(mision_gelatina_completa)
	if str(mision_gelatina_guardada.get("estado", "")) != "completada" or int(mision_gelatina_guardada.get("gelatina", 0)) != servidor.GELATINA_LIMO_REQUERIDA_MISION:
		push_error("Error: la entrega completada de gelatina no se normalizó para guardado/carga.")
		servidor.free()
		quit(1)
		return
	print("OK: la misión de gelatina cuenta botín, conserva entregas incompletas y recompensa 120 XP al entregar tres.")

	# Atributos: puntos por nivel, daño por fuerza, salud por vitalidad y validación autoritativa.
	var progresion_legacy: Dictionary = servidor._normalizar_progresion({"level": 3, "xp": 12})
	if int(progresion_legacy.get("attribute_points", 0)) != 2:
		push_error("Error: un guardado anterior debe convertir los niveles existentes en puntos de atributo disponibles.")
		servidor.free()
		quit(1)
		return
	var progresion_invalidada: Dictionary = servidor._normalizar_progresion({"level": 3, "strength": 99, "vitality": 99})
	if int(progresion_invalidada.get("strength", 0)) != 2 or int(progresion_invalidada.get("vitality", 0)) != 0 or int(progresion_invalidada.get("attribute_points", 0)) != 0:
		push_error("Error: la normalización no debe permitir gastar más puntos que niveles ganados.")
		servidor.free()
		quit(1)
		return
	servidor.progresion_jugadores[id_jugador] = {"level": 3, "xp": 0, "strength": 0, "vitality": 0}
	servidor.equipamiento_jugadores[id_jugador] = {"arma": ""}
	servidor.salud_jugadores[id_jugador] = {"hp": 70, "hp_max": 100, "muerto": false}
	var jugadores_atributos: Dictionary = servidor.jugadores[id_jugador]
	servidor.entidades[3]["activo"] = true
	servidor.entidades[3]["estado"] = "patrullando"
	servidor.entidades[3]["hp"] = 100
	servidor.entidades[3]["x"] = float(jugadores_atributos.get("x", 0.0))
	servidor.entidades[3]["y"] = float(jugadores_atributos.get("y", 0.0))
	servidor.entidades[3]["z"] = float(jugadores_atributos.get("z", 0.0))
	var resultado_fuerza: Dictionary = servidor._procesar_asignar_atributo(id_jugador, {"attribute": "strength"})
	if not bool(resultado_fuerza.get("success", false)) or int(servidor._datos_progresion(id_jugador).get("strength", 0)) != 1 or int(servidor._datos_progresion(id_jugador).get("attribute_points", -1)) != 1:
		push_error("Error: asignar fuerza debió gastar un punto y conservar el segundo.")
		servidor.free()
		quit(1)
		return
	servidor.tiempos_ultimo_ataque[id_jugador] = -100.0
	ultimo_resultado.clear()
	servidor._procesar_ataque(id_jugador, {"target_id": 3})
	if int(ultimo_resultado.get("damage", 0)) != 21:
		push_error("Error: un punto de fuerza debe aumentar en dos el daño de nivel 3 sin equipo.")
		servidor.free()
		quit(1)
		return
	var resultado_vitalidad: Dictionary = servidor._procesar_asignar_atributo(id_jugador, {"attribute": "vitality"})
	var salud_vitalidad: Dictionary = servidor._datos_salud_jugador(id_jugador)
	if not bool(resultado_vitalidad.get("success", false)) or int(salud_vitalidad.get("hp_max", 0)) != 110 or int(salud_vitalidad.get("hp", 0)) != 80 or int(servidor._datos_progresion(id_jugador).get("attribute_points", -1)) != 0:
		push_error("Error: un punto de vitalidad debe añadir 10 a vida máxima y actual, consumiendo el último punto disponible.")
		servidor.free()
		quit(1)
		return
	var rechazo_sin_puntos: Dictionary = servidor._procesar_asignar_atributo(id_jugador, {"attribute": "strength"})
	var rechazo_atributo_invalido: Dictionary = servidor._procesar_asignar_atributo(id_jugador, {"attribute": "luck"})
	if str(rechazo_sin_puntos.get("reason", "")) != "no_points" or str(rechazo_atributo_invalido.get("reason", "")) != "invalid_attribute":
		push_error("Error: el servidor debió rechazar atributos desconocidos o asignación sin puntos.")
		servidor.free()
		quit(1)
		return
	servidor.progresion_jugadores[id_jugador] = {"level": 4, "xp": 0, "strength": 1, "vitality": 1}
	servidor.salud_jugadores[id_jugador] = {"hp": 0, "hp_max": 110, "muerto": true}
	var rechazo_derrotado: Dictionary = servidor._procesar_asignar_atributo(id_jugador, {"attribute": "strength"})
	if str(rechazo_derrotado.get("reason", "")) != "player_dead":
		push_error("Error: un jugador derrotado no debe asignar atributos.")
		servidor.free()
		quit(1)
		return
	print("OK: Fuerza añade 2 daño, Vitalidad añade 10 a vida máxima/actual, niveles antiguos reciben puntos y el servidor rechaza asignaciones inválidas o derrotadas.")

	servidor.free()
	quit(0)
