extends SceneTree
const Fabrica := preload("res://scripts/cliente/FabricaEntidades.gd")
func _initialize() -> void:
	var prueba := Fabrica.crear("prueba", 1)
	var npc := Fabrica.crear("npc", 2)
	var desconocida := Fabrica.crear("tipo_inexistente", 3)
	if prueba == null or npc == null or desconocida != null:
		push_error("Fallo de creacion")
		quit(1)
		return
	if prueba.get_child_count() != 1 or npc.get_child_count() != 2:
		push_error("Mallas incorrectas")
		quit(1)
		return
	print("OK: prueba (1 malla)")
	print("OK: npc (2 mallas)")
	print("OK: tipo desconocido rechazado")
	prueba.free()
	npc.free()
	quit(0)
