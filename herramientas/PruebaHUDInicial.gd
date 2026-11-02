extends SceneTree

class MainSoloHUD extends "res://Main.gd":
	func _ready() -> void:
		pass

func _initialize() -> void:
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	var main := MainSoloHUD.new()
	root.add_child(main)
	main._crear_hud()

	var jugador := Node3D.new()
	jugador.name = "JugadorDePrueba"
	main.add_child(jugador)
	var modelo := Node3D.new()
	modelo.name = "Modelo"
	jugador.add_child(modelo)
	var malla := MeshInstance3D.new()
	malla.mesh = SphereMesh.new()
	modelo.add_child(malla)

	var hud: Node = main.get("hud_inicial")
	hud.call("configurar_jugador", jugador, {"hp": 72, "hp_max": 120}, {"level": 2})
	main._al_cambiar_salud_jugador({"hp": 64, "hp_max": 120, "muerto": false})
	main._al_cambiar_progresion({"level": 3, "xp": 20, "xp_to_next": 100})

	if hud.get("modelo_retrato") == null:
		_fallar("El retrato no clonó el modelo del jugador.")
		return
	var minimapa: Node = hud.get("minimapa_jugador")
	if minimapa.get("jugador") != jugador:
		_fallar("El minimapa no está conectado al jugador local.")
		return
	if str(hud.get("etiqueta_personaje").text) != "Caballero · Nivel 3":
		_fallar("El marco del jugador no recibió el nivel real.")
		return
	var barra_vida: ProgressBar = hud.get("barra_salud_jugador")
	if int(barra_vida.value) != 64 or int(barra_vida.max_value) != 120:
		_fallar("La barra de vida no refleja la salud recibida.")
		return
	var barra_mana: ProgressBar = hud.get("barra_mana_jugador")
	if barra_mana.value != 0.0 or barra_mana.tooltip_text.is_empty():
		_fallar("El maná dejó de ser un espacio visual sin sistema activo.")
		return
	var espacios: Array = hud.get("espacios_accion")
	if espacios.size() != 6:
		_fallar("La barra no contiene exactamente seis espacios visuales.")
		return
	for espacio in espacios:
		if espacio.mouse_filter != Control.MOUSE_FILTER_IGNORE:
			_fallar("Un espacio de acción intercepta controles del juego.")
			return

	var enemigo := Node3D.new()
	enemigo.name = "LoboDePrueba"
	main.add_child(enemigo)
	main._al_cambiar_objetivo(7, {"name": "Lobo del Bosque", "hp": 28, "hp_max": 60}, enemigo)
	var panel_objetivo: Control = main.get("panel_objetivo")
	var nombre_objetivo: Label = main.get("etiqueta_objetivo_nombre")
	var barra_objetivo: ProgressBar = main.get("barra_vida_objetivo")
	if not panel_objetivo.visible or nombre_objetivo.text != "Lobo del Bosque":
		_fallar("El marco no muestra el objetivo seleccionado.")
		return
	if int(barra_objetivo.value) != 28 or int(barra_objetivo.max_value) != 60:
		_fallar("La barra de objetivo no refleja la vida recibida.")
		return
	main._al_cambiar_objetivo(0, {}, null)
	if panel_objetivo.visible:
		_fallar("El marco de objetivo siguió visible después de limpiar selección.")
		return

	print("OK: Main conecta retrato, vida, maná visual, seis espacios, objetivo y minimapa.")
	quit(0)

func _fallar(mensaje: String) -> void:
	push_error(mensaje)
	quit(1)
