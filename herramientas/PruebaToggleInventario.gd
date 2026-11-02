extends SceneTree

const MainScript := preload("res://Main.gd")

func _initialize() -> void:
	var main = MainScript.new()
	root.add_child(main)
	main._crear_hud()

	var panel = main.get("panel_inventario")
	if panel == null:
		push_error("Error: panel_inventario es null tras _crear_hud.")
		main.free()
		quit(1)
		return

	# Comprobar 1: Debe iniciar oculto
	if panel.visible:
		push_error("Error: el panel de inventario debe iniciar oculto.")
		main.free()
		quit(1)
		return
	print("OK: inventario inicia oculto.")

	# Comprobar 2: Alternar con _alternar_inventario (B)
	main._alternar_inventario()
	if not panel.visible:
		push_error("Error: _alternar_inventario debió abrir el panel.")
		main.free()
		quit(1)
		return
	print("OK: primer toggle abre el inventario.")

	main._alternar_inventario()
	if panel.visible:
		push_error("Error: segundo toggle debió cerrar el panel.")
		main.free()
		quit(1)
		return
	print("OK: segundo toggle cierra el inventario.")

	# Comprobar 3: Simular tecla B por evento _input
	var ev := InputEventKey.new()
	ev.keycode = KEY_B
	ev.pressed = true
	main._input(ev)
	if not panel.visible:
		push_error("Error: tecla B debió abrir el panel vía _input.")
		main.free()
		quit(1)
		return
	print("OK: evento tecla B abre el inventario.")

	main._input(ev)
	if panel.visible:
		push_error("Error: segundo evento tecla B debió cerrar el panel.")
		main.free()
		quit(1)
		return
	print("OK: segundo evento tecla B cierra el inventario.")

	main.free()
	print("OK: Pruebas de toggle de inventario completadas con éxito.")
	quit(0)