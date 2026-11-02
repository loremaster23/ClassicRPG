extends SceneTree

const EscenaJugador := preload("res://Personajes/Jugador.tscn")
const MultijugadorScript := preload("res://scripts/cliente/Multijugador.gd")

var respuesta_ataque := {}

func _initialize() -> void:
	# 1. Verificar animación en Jugador
	var jugador = EscenaJugador.instantiate()
	root.add_child(jugador)
	if jugador.espada == null:
		jugador.espada = jugador.get_node("Modelo/Espada")
		jugador.modelo = jugador.get_node("Modelo")
		jugador.torso = jugador.get_node("Modelo/Torso")
		jugador.pierna_izq = jugador.get_node("Modelo/PiernaIzq")
		jugador.pierna_der = jugador.get_node("Modelo/PiernaDer")
		jugador.brazo_izq = jugador.get_node("Modelo/BrazoIzq")
		jugador.brazo_der = jugador.get_node("Modelo/BrazoDer")
		jugador.capa = jugador.get_node("Modelo/Capa")
		jugador.hombrera_izq = jugador.get_node("Modelo/HombreraIzq")
		jugador.hombrera_der = jugador.get_node("Modelo/HombreraDer")
		jugador._ready()

	if not jugador.has_method("animar_ataque"):
		push_error("Error: Jugador no tiene animar_ataque().")
		quit(1)
		return

	if jugador.tiempo_ataque != 0.0:
		push_error("Error: tiempo_ataque inicial debio ser 0.")
		quit(1)
		return

	jugador.animar_ataque()
	if jugador.tiempo_ataque <= 0.0:
		push_error("Error: animar_ataque() no configuro tiempo_ataque.")
		quit(1)
		return

	var rot_inicial: Vector3 = jugador.espada.rotation
	jugador.call("_animar", 0.1)
	if jugador.espada.rotation == rot_inicial:
		push_error("Error: la espada debio rotar por el arco de ataque.")
		quit(1)
		return
	jugador.animar_ataque("golpe_pesado")
	if jugador.tiempo_ataque <= jugador.DURACION_ATAQUE or jugador.potencia_animacion_ataque <= 1.0:
		push_error("Error: el golpe pesado debio usar una animacion mas larga y potente que el golpe normal.")
		quit(1)
		return

	# 2. Verificar Multijugador atacar_objetivo sin objetivo
	var multi = MultijugadorScript.new()
	root.add_child(multi)
	multi.iniciar(jugador)

	multi.resultado_ataque.connect(func(datos: Dictionary):
		respuesta_ataque = datos.duplicate(true)
	)

	multi.atacar_objetivo()
	if respuesta_ataque.get("success", true) != false or respuesta_ataque.get("reason", "") != "no_target":
		push_error("Error: atacar_objetivo sin objetivo debio emitir reason=no_target.")
		quit(1)
		return

	# Verificar que animar_ataque fue llamado al pulsar habilidad
	if jugador.tiempo_ataque <= 0.0:
		push_error("Error: atacar_objetivo debio disparar animar_ataque en jugador_local.")
		quit(1)
		return
	multi.atacar_objetivo("golpe_pesado")
	if jugador.tiempo_ataque <= jugador.DURACION_ATAQUE or jugador.potencia_animacion_ataque <= 1.0:
		push_error("Error: atacar_objetivo no activó la animacion pesada solicitada.")
		quit(1)
		return
	multi.id_local = 101
	multi.jugadores_remotos[202] = jugador
	jugador.tiempo_ataque = 0.0
	multi._procesar_mensaje({"type": "player_attack", "id": 202, "skill_id": "golpe_pesado"})
	if jugador.tiempo_ataque <= 0.0 or jugador.potencia_animacion_ataque <= 1.0:
		push_error("Error: player_attack no replico el golpe pesado al jugador remoto.")
		quit(1)
		return

	jugador.tiempo_ataque = 0.0
	multi._procesar_mensaje({"type": "player_attack", "id": 101})
	if jugador.tiempo_ataque != 0.0:
		push_error("Error: el evento remoto no debe duplicar la animacion local.")
		quit(1)
		return

	print("OK: PruebaAnimacionCombate verificada con éxito.")
	print("OK: Evento player_attack anima al remoto sin repetirlo en el atacante.")
	quit(0)
