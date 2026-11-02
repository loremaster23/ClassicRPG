extends SceneTree

const EscenaMenu := preload("res://MenuInicio.tscn")


func _initialize() -> void:
	call_deferred("_probar_menu")


func _probar_menu() -> void:
	var ruta := "C:/Users/Bruker/Documents/Codex/classicrpg_menu_test_%d.json" % Time.get_ticks_usec()
	var menu := EscenaMenu.instantiate()
	menu.set("ruta_guardado_local", ruta)
	root.add_child(menu)
	await process_frame
	if menu.get("boton_jugar").disabled or not menu.get("boton_continuar").disabled or not menu.get("boton_borrar").disabled:
		push_error("El menú sin guardado debe permitir nueva partida y desactivar continuar/borrar.")
		quit(1)
		return
	var archivo := FileAccess.open(ruta, FileAccess.WRITE)
	if archivo == null:
		push_error("No se pudo preparar el guardado temporal de la prueba del menú.")
		quit(1)
		return
	archivo.store_string("{}"); archivo.close()
	menu.call("_actualizar_opciones")
	if not menu.get("boton_jugar").disabled or menu.get("boton_continuar").disabled or menu.get("boton_borrar").disabled:
		DirAccess.remove_absolute(ruta)
		push_error("El menú con guardado debe desactivar nueva partida y permitir continuar/borrar.")
		quit(1)
		return
	var dialogo: ConfirmationDialog = menu.get("dialogo_borrar")
	if not dialogo.confirmed.is_connected(Callable(menu, "_borrar_guardado_confirmado")):
		DirAccess.remove_absolute(ruta)
		push_error("La eliminación del guardado debe exigir el diálogo de confirmación.")
		quit(1)
		return
	menu.call("_borrar_guardado_confirmado")
	if FileAccess.file_exists(ruta) or menu.get("boton_jugar").disabled or not menu.get("boton_continuar").disabled:
		push_error("Tras confirmar el borrado, el menú debe habilitar una nueva partida.")
		quit(1)
		return
	menu.queue_free()
	print("OK: el menú conserva el guardado y solo habilita reinicio después de confirmación explícita.")
	quit(0)
