extends SceneTree

const MultijugadorScript := preload("res://scripts/cliente/Multijugador.gd")

var objetivo_recibido_id := -1
var datos_recibidos := {}

func _initialize() -> void:
	var multi = MultijugadorScript.new()
	root.add_child(multi)

	multi.objetivo_cambiado.connect(func(id: int, datos: Dictionary, _nodo: Node3D):
		objetivo_recibido_id = id
		datos_recibidos = datos
	)

	# Simular entidades remotas
	var n1 := Node3D.new()
	n1.position = Vector3(0, 0, 0)
	root.add_child(n1)
	multi.entidades_remotas[1] = n1
	multi.datos_entidades[1] = {"name": "Entidad 1", "hp": 100, "hp_max": 100, "type": "prueba", "estado": "activo"}

	var n2 := Node3D.new()
	n2.position = Vector3(3, 0, 0)
	root.add_child(n2)
	multi.entidades_remotas[2] = n2
	multi.datos_entidades[2] = {"name": "Habitante", "hp": 100, "hp_max": 100, "type": "npc", "estado": "idle"}

	var n3 := Node3D.new()
	n3.position = Vector3(-3, 0, 0)
	root.add_child(n3)
	multi.entidades_remotas[3] = n3
	multi.datos_entidades[3] = {"name": "Lobo del Bosque", "hp": 60, "hp_max": 60, "type": "lobo", "estado": "patrullando"}

	# Prueba 1: Seleccionar siguiente objetivo (debe elegir el primero)
	multi.seleccionar_siguiente_objetivo()
	if multi.id_objetivo <= 0 or objetivo_recibido_id != multi.id_objetivo:
		push_error("Error: no se selecciono el primer objetivo.")
		quit(1)
		return

	var primer_id: int = multi.id_objetivo

	# Prueba 2: Ciclar al siguiente objetivo
	multi.seleccionar_siguiente_objetivo()
	if multi.id_objetivo == primer_id or multi.id_objetivo <= 0:
		push_error("Error: no ciclo al siguiente objetivo.")
		quit(1)
		return

	# Prueba 3: Deseleccionar
	multi.seleccionar_objetivo(0)
	if multi.id_objetivo != 0 or objetivo_recibido_id != 0:
		push_error("Error: no deselecciono correctamente.")
		quit(1)
		return

	# Prueba 4: Seleccionar por ID directo
	multi.seleccionar_objetivo(2)
	if multi.id_objetivo != 2 or objetivo_recibido_id != 2 or str(datos_recibidos.get("name", "")) != "Habitante":
		push_error("Error: seleccionar_objetivo por ID falló.")
		quit(1)
		return

	# Prueba 5: Selección por raycast simulado (apuntando hacia n3)
	var hit_id := multi.seleccionar_objetivo_por_rayo(Vector3(-3, 0, 5), Vector3(0, 0, -1), 10.0)
	if hit_id != 3 or multi.id_objetivo != 3:
		push_error("Error: selección por raycast falló al detectar n3.")
		quit(1)
		return

	# Prueba 6: Selección por raycast hacia la nada (debe retornar 0 y no deseleccionar el activo)
	var miss_id := multi.seleccionar_objetivo_por_rayo(Vector3(100, 0, 100), Vector3(0, 1, 0), 10.0)
	if miss_id != 0 or multi.id_objetivo != 3:
		push_error("Error: raycast fallido no debe alterar el objetivo actual.")
		quit(1)
		return

	print("OK: Seleccion de objetivos y senales de Targeting verificadas exitosamente.")

	n1.free()
	n2.free()
	n3.free()
	multi.free()
	quit(0)
