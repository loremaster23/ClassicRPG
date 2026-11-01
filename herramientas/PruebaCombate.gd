extends SceneTree

const ServidorScript := preload("res://scripts/servidor/Servidor.gd")

var ultimo_resultado: Dictionary = {}

func _al_recibir_ataque(_id: int, res: Dictionary) -> void:
	ultimo_resultado = res.duplicate(true)


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

	# 6. Ataque a objetivo ya muerto
	ultimo_resultado.clear()
	servidor.tiempos_ultimo_ataque[id_jugador] = -100.0
	servidor._procesar_ataque(id_jugador, {"target_id": 3})
	if ultimo_resultado.get("success", true) != false or ultimo_resultado.get("reason", "") != "target_dead":
		push_error("Error: atacar a un muerto debio fallar con target_dead.")
		servidor.free()
		quit(1)
		return

	print("OK: Validacion de objetivo invalido correcta.")
	print("OK: Validacion de rango melee (out_of_range) correcta.")
	print("OK: Aplicacion de danio y reduccion de HP correcta.")
	print("OK: Tiempo de recarga (on_cooldown) verificado.")
	print("OK: Transicion a estado muerto y activo=false comprobada.")
	print("OK: Rechazo de ataque a entidad muerta (target_dead) comprobado.")

	servidor.free()
	quit(0)
