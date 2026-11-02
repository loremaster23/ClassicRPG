extends SceneTree

const ServidorScript := preload("res://scripts/servidor/Servidor.gd")

var ultimo_resultado: Dictionary = {}
var actualizaciones_recibidas: Array[Dictionary] = []

func _al_recibir_ataque(_id: int, res: Dictionary) -> void:
	ultimo_resultado = res.duplicate(true)

func _initialize() -> void:
	var servidor = ServidorScript.new()
	servidor._inicializar_mundo()
	servidor.ataque_procesado.connect(_al_recibir_ataque)

	var c1 := 101
	var c2 := 102

	# Conectar cliente 1 y cliente 2 al servidor
	servidor.jugadores[c1] = {
		"x": -3.5, "y": 0.0, "z": 0.5,
		"yaw": 0.0, "sprint": false, "en_el_aire": false,
		"ultima_secuencia": 0
	}
	servidor.jugadores[c2] = {
		"x": -2.8, "y": 0.0, "z": -0.5,
		"yaw": 0.0, "sprint": false, "en_el_aire": false,
		"ultima_secuencia": 0
	}

	# 1. Verificar capacidad para 2 clientes
	if servidor.jugadores.size() != 2:
		push_error("Error: el servidor debe admitir 2 clientes simultaneos.")
		servidor.free()
		quit(1)
		return

	# 2. Cliente 1 ataca al Lobo (id 3, 60 HP)
	ultimo_resultado.clear()
	servidor._procesar_ataque(c1, {"target_id": 3})
	if not bool(ultimo_resultado.get("success", false)) or int(ultimo_resultado.get("target_hp", 0)) != 45:
		push_error("Error: ataque de cliente 1 debio dejar al lobo en 45 HP.")
		servidor.free()
		quit(1)
		return

	if servidor.entidades[3]["hp"] != 45:
		push_error("Error: HP del lobo en servidor no coincide con 45.")
		servidor.free()
		quit(1)
		return

	# 3. Cliente 2 ataca inmediatamente (debe permitirse porque cada cliente tiene su propio cooldown)
	ultimo_resultado.clear()
	servidor._procesar_ataque(c2, {"target_id": 3})
	if not bool(ultimo_resultado.get("success", false)) or int(ultimo_resultado.get("target_hp", 0)) != 30:
		push_error("Error: ataque independiente de cliente 2 debio tener exito y dejar al lobo en 30 HP.")
		servidor.free()
		quit(1)
		return

	if servidor.entidades[3]["hp"] != 30:
		push_error("Error: HP del lobo en servidor debio ser 30 tras ataque de cliente 2.")
		servidor.free()
		quit(1)
		return

	# 4. Cooperación de combate hasta derribar a la criatura
	servidor.tiempos_ultimo_ataque[c1] = -100.0
	servidor._procesar_ataque(c1, {"target_id": 3}) # Deja al lobo en 15 HP
	servidor.tiempos_ultimo_ataque[c2] = -100.0
	servidor._procesar_ataque(c2, {"target_id": 3}) # Golpe letal: 0 HP

	if servidor.entidades[3]["hp"] != 0 or servidor.entidades[3]["estado"] != "muerto" or servidor.entidades[3]["activo"] != false:
		push_error("Error: tras ataques conjuntos el lobo debio morir (0 HP, inactivo).")
		servidor.free()
		quit(1)
		return
	var botin_c1: Dictionary = servidor.inventarios.get(c1, {})
	var botin_c2: Dictionary = servidor.inventarios.get(c2, {})
	if not botin_c1.is_empty():
		push_error("Error: el jugador que no dio el golpe final no debe recibir el botin.")
		servidor.free()
		quit(1)
		return
	if int(botin_c2.get("colmillo_lobo", 0)) != 1 or int(botin_c2.get("piel_lobo", 0)) != 1:
		push_error("Error: el jugador que dio el golpe final debe recibir ambos materiales.")
		servidor.free()
		quit(1)
		return
	var progreso_c2: Dictionary = servidor.progresion_jugadores.get(c2, {})
	if int(progreso_c2.get("xp", 0)) != 25:
		push_error("Error: solo el jugador del golpe final debe recibir 25 XP.")
		servidor.free()
		quit(1)
		return

	# 5. Respawn autoritativo sincronizado
	servidor._actualizar_respawn(servidor.TIEMPO_RESPAWN + 0.5)
	if servidor.entidades[3]["hp"] != 60 or servidor.entidades[3]["estado"] != "patrullando" or servidor.entidades[3]["activo"] != true:
		push_error("Error: respawn fallido tras muerte en combate multijugador.")
		servidor.free()
		quit(1)
		return

	# 6. Las recargas de la habilidad pesada se mantienen aisladas por jugador.
	servidor.tiempos_ultimo_ataque[c1] = -100.0
	servidor.tiempos_ultimo_ataque[c2] = -100.0
	servidor.tiempos_ultimo_golpe_pesado[c1] = Time.get_ticks_msec() / 1000.0
	servidor.tiempos_ultimo_golpe_pesado[c2] = -100.0
	ultimo_resultado.clear()
	servidor._procesar_ataque(c1, {"target_id": 3, "skill_id": "golpe_pesado"})
	if bool(ultimo_resultado.get("success", true)) or str(ultimo_resultado.get("reason", "")) != "skill_on_cooldown":
		push_error("Error: el cliente 1 debio conservar su recarga de golpe pesado.")
		servidor.free()
		quit(1)
		return
	ultimo_resultado.clear()
	servidor._procesar_ataque(c2, {"target_id": 3, "skill_id": "golpe_pesado"})
	if not bool(ultimo_resultado.get("success", false)) or int(ultimo_resultado.get("damage", 0)) != 30:
		push_error("Error: la recarga del cliente 1 no debio bloquear el golpe pesado del cliente 2.")
		servidor.free()
		quit(1)
		return

	print("OK: Servidor admite 2 clientes simultaneos.")
	print("OK: Cooldowns independientes por cliente verificados.")
	print("OK: La recarga del golpe pesado del cliente 1 no bloquea la habilidad del cliente 2.")
	print("OK: Combate cooperativo de 2 clientes sincronizado (60 -> 45 -> 30 -> 15 -> 0 HP).")
	print("OK: Botin y XP asignados solo al jugador del golpe final.")
	print("OK: Reaparicion autoritativa tras combate multijugador verificada.")

	servidor.free()
	quit(0)
