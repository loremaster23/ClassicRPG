extends SceneTree

const ServidorScript := preload("res://scripts/servidor/Servidor.gd")

func _initialize() -> void:
	var servidor = ServidorScript.new()
	servidor._inicializar_mundo()

	var entidades: Dictionary = servidor.entidades
	if entidades.size() != 3:
		push_error("Error: se esperaban 3 entidades iniciales.")
		servidor.free()
		quit(1)
		return

	var e1: Dictionary = servidor._obtener_entidad(1)
	var e2: Dictionary = servidor._obtener_entidad(2)
	var e3: Dictionary = servidor._obtener_entidad(3)

	for campo in ["id", "type", "name", "x", "y", "z", "yaw", "hp", "hp_max", "estado", "activo"]:
		if not e1.has(campo) or not e2.has(campo) or not e3.has(campo):
			push_error("Error: falta el campo '%s' en la entidad." % campo)
			servidor.free()
			quit(1)
			return

	if e3["type"] != "lobo" or e3["name"] != "Lobo del Bosque" or e3["hp"] != 60 or e3["estado"] != "patrullando":
		push_error("Error: datos iniciales del Lobo incorrectos.")
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
	print("OK: _eliminar_entidad verificado exitosamente.")

	servidor.free()
	quit(0)
