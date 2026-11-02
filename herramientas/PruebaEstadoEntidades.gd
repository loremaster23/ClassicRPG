extends SceneTree

const ServidorScript := preload("res://scripts/servidor/Servidor.gd")

func _initialize() -> void:
	var servidor = ServidorScript.new()
	servidor._inicializar_mundo()

	var entidades: Dictionary = servidor.entidades
	if entidades.size() != 5:
		push_error("Error: se esperaban 5 entidades iniciales.")
		servidor.free()
		quit(1)
		return

	var e1: Dictionary = servidor._obtener_entidad(1)
	var e2: Dictionary = servidor._obtener_entidad(2)
	var e3: Dictionary = servidor._obtener_entidad(3)
	var e4: Dictionary = servidor._obtener_entidad(4)
	var e5: Dictionary = servidor._obtener_entidad(5)

	for campo in ["id", "type", "name", "x", "y", "z", "yaw", "hp", "hp_max", "estado", "activo"]:
		if not e1.has(campo) or not e2.has(campo) or not e3.has(campo) or not e4.has(campo) or not e5.has(campo):
			push_error("Error: falta el campo '%s' en la entidad." % campo)
			servidor.free()
			quit(1)
			return

	if e3["type"] != "lobo" or e3["name"] != "Lobo del Bosque" or e3["hp"] != 60 or e3["estado"] != "patrullando":
		push_error("Error: datos iniciales del Lobo incorrectos.")
		servidor.free()
		quit(1)
		return

	if e4.get("type", "") != "jabali" or e4.get("name", "") != "Jabalí del Bosque" or int(e4.get("hp", 0)) != 80 or str(e4.get("estado", "")) != "patrullando":
		push_error("Error: estadísticas o estado inicial del jabalí incorrectos.")
		servidor.free()
		quit(1)
		return
	if e5.get("type", "") != "limo" or e5.get("name", "") != "Limo del Bosque" or int(e5.get("hp", 0)) != 45 or str(e5.get("estado", "")) != "patrullando":
		push_error("Error: estadísticas o estado inicial del limo incorrectos.")
		servidor.free()
		quit(1)
		return
	servidor.jugadores[99] = {"x": 8.0, "y": 0.0, "z": -8.0}
	servidor._actualizar_ia_entidades(4.1)
	if float(servidor.entidades[4].get("x", 8.0)) == 8.0 or str(servidor.entidades[4].get("estado", "")) != "patrullando":
		push_error("Error: el jabalí debio avanzar por su patrulla autoritativa.")
		servidor.free()
		quit(1)
		return
	servidor._actualizar_ia_entidades(0.5)
	if float(servidor.entidades[5].get("x", -10.0)) == -10.0 or str(servidor.entidades[5].get("estado", "")) != "patrullando":
		push_error("Error: el limo debio avanzar por su patrulla autoritativa.")
		servidor.free()
		quit(1)
		return

	# Prueba de actualizacion de estado del lobo
	servidor._actualizar_entidad(3, {
		"hp": 40,
		"estado": "en_combate",
		"x": -3.5,
		"yaw": 0.85
	})

	var e3_actualizada: Dictionary = servidor._obtener_entidad(3)
	if e3_actualizada["hp"] != 40 or e3_actualizada["estado"] != "en_combate" or e3_actualizada["x"] != -3.5 or e3_actualizada["yaw"] != 0.85:
		push_error("Error: _actualizar_entidad no aplico los cambios correctamente al lobo.")
		servidor.free()
		quit(1)
		return

	# Prueba de eliminacion de entidad
	servidor._eliminar_entidad(1)
	if servidor.entidades.has(1):
		push_error("Error: _eliminar_entidad no removio la entidad.")
		servidor.free()
		quit(1)
		return

	print("OK: Entidades inicializadas con campos de estado y ciclo de vida.")
	print("OK: Lobo verificado con estado 'patrullando' y actualizacion probada.")
	print("OK: Jabalí verificado con patrulla autoritativa.")
	print("OK: Limo verificado con estadísticas y patrulla autoritativa.")
	print("OK: _eliminar_entidad verificado exitosamente.")

	servidor.free()
	quit(0)
