extends SceneTree

var fallos: Array[String] = []


func _check(condicion: bool, mensaje: String) -> void:
	if condicion:
		print("[OK] ", mensaje)
	else:
		push_error("[FALLO] " + mensaje)
		fallos.append(mensaje)


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var escena := load("res://Personajes/Jugador.tscn") as PackedScene
	_check(escena != null, "La escena del jugador carga")
	if escena == null:
		quit(1)
		return

	var suelo := StaticBody3D.new()
	var forma_suelo := CollisionShape3D.new()
	var caja_suelo := BoxShape3D.new()
	caja_suelo.size = Vector3(20.0, 1.0, 20.0)
	forma_suelo.shape = caja_suelo
	suelo.position.y = -0.5
	suelo.add_child(forma_suelo)
	root.add_child(suelo)

	var jugador := escena.instantiate() as CharacterBody3D
	root.add_child(jugador)
	jugador.es_local = false
	for indice in range(3):
		await physics_frame

	var cabeza := jugador.get_node_or_null("Modelo/VisualQuaternius/CabezaBaseQuaternius") as Node3D
	_check(cabeza != null, "La cabeza oficial de UBC está montada en el jugador")
	if cabeza == null:
		quit(1)
		return

	_check(jugador.esqueletos_quaternius.size() == 2, "El controlador encuentra los esqueletos del atuendo y la cabeza")
	if jugador.esqueletos_quaternius.size() != 2:
		quit(1)
		return

	var datos_ranger: Dictionary = jugador.esqueletos_quaternius[0]
	var esqueleto := datos_ranger["esqueleto"] as Skeleton3D
	var datos_cabeza: Dictionary = jugador.esqueletos_quaternius[1]
	var esqueleto_cabeza := datos_cabeza["esqueleto"] as Skeleton3D
	var mallas_cabeza := esqueleto_cabeza.find_children("*", "MeshInstance3D", true, false)
	_check(mallas_cabeza.size() == 3, "El esqueleto retargeteado conserva rostro, ojos y cejas")
	var superficies_texturadas := 0
	for nodo in mallas_cabeza:
		var malla := nodo as MeshInstance3D
		_check(malla.visible and malla.mesh != null, "Malla facial visible e importada: %s" % malla.name)
		for indice in range(malla.mesh.get_surface_count()):
			var material := malla.get_active_material(indice)
			if material is BaseMaterial3D and (material as BaseMaterial3D).albedo_texture != null:
				superficies_texturadas += 1
	_check(superficies_texturadas >= 3, "Las texturas de piel, ojos y cejas siguen asignadas")
	var hueso_brazo_izq := esqueleto.find_bone("upperarm_l")
	var hueso_brazo_der := esqueleto.find_bone("upperarm_r")
	var hueso_muslo_izq := esqueleto.find_bone("thigh_l")
	var hueso_muslo_der := esqueleto.find_bone("thigh_r")
	_check(hueso_brazo_izq >= 0 and hueso_brazo_der >= 0, "El rig conserva ambos huesos de brazo")
	_check(hueso_muslo_izq >= 0 and hueso_muslo_der >= 0, "El rig conserva ambos huesos de pierna")
	var cabeza_rig_ranger := esqueleto.find_bone("Head")
	var cabeza_rig_base := esqueleto_cabeza.find_bone("Head")
	var resto_cabeza_ranger := esqueleto.get_bone_global_rest(cabeza_rig_ranger)
	var resto_cabeza_base := esqueleto_cabeza.get_bone_global_rest(cabeza_rig_base)
	_check(
		resto_cabeza_ranger.origin.distance_to(resto_cabeza_base.origin) < 0.001,
		"La cabeza y el atuendo comparten la posición de reposo del hueso Head"
	)

	_check(jugador.animacion_quaternius_activa, "Universal Animation Library queda activa en el jugador")
	var arbol := jugador.animation_tree_quaternius as AnimationTree
	_check(arbol != null and arbol.active, "AnimationTree está activo")
	var estados := arbol.tree_root as AnimationNodeStateMachine
	_check(estados != null, "AnimationTree utiliza una máquina de estados")
	var locomocion := estados.get_node("Locomocion") as AnimationNodeBlendSpace2D
	_check(locomocion != null and locomocion.get_blend_point_count() == 9, "El BlendSpace incluye reposo y ocho direcciones")
	var nodo_idle := locomocion.get_blend_point_node(0) as AnimationNodeAnimation
	_check(
		nodo_idle != null and nodo_idle.animation == &"Idle" and locomocion.get_blend_point_position(0) == Vector2.ZERO,
		"Idle de Quaternius ocupa el centro de locomoción"
	)
	for indice in range(1, 9):
		var nodo_caminar := locomocion.get_blend_point_node(indice) as AnimationNodeAnimation
		_check(nodo_caminar != null and nodo_caminar.animation == &"Walk", "La entrada direccional %d usa Walk de Quaternius" % indice)
	var animation_player := jugador.rig_animaciones_quaternius.find_child("AnimationPlayer", true, false) as AnimationPlayer
	for nombre_clip in ["Idle", "Walk", "Jog_Fwd", "Sprint", "Jump_Start", "Jump", "Jump_Land"]:
		_check(animation_player.has_animation(nombre_clip), "Clip oficial disponible: %s" % nombre_clip)
	var retarget := jugador.esqueleto_animaciones_quaternius.find_child("RetargetMaleRanger", true, false) as RetargetModifier3D
	_check(retarget != null and retarget.profile.bone_size == 65, "RetargetModifier3D mapea el rig humanoide de 65 huesos")
	_check(retarget != null and retarget.get_child_count() == 2, "El retarget anima el Ranger y la cabeza desde el mismo rig")
	_check(estados.has_transition("Locomocion", "SaltoInicio"), "Existe la transición de locomoción a salto")
	_check(estados.has_transition("SaltoInicio", "Aire"), "Existe la transición del impulso al ciclo aéreo")
	_check(estados.has_transition("Aire", "Caida"), "Existe la transición de ascenso a caída")
	_check(estados.has_transition("Caida", "Aterrizaje"), "Existe la transición de caída a aterrizaje")

	# El eje visual y los ocho puntos de marcha siguen al movimiento sin rotar Modelo.
	var yaw_logico: float = jugador.modelo.rotation.y
	for direccion in [
		Vector3(0, 0, -6), Vector3(4.24, 0, -4.24), Vector3(6, 0, 0),
		Vector3(4.24, 0, 4.24), Vector3(0, 0, 6), Vector3(-4.24, 0, 4.24),
		Vector3(-6, 0, 0), Vector3(-4.24, 0, -4.24)
	]:
		jugador.velocity = direccion
		jugador._orientar_visual_quaternius(1.0)
		jugador._actualizar_arbol_animacion_quaternius(direccion.length())
		await process_frame
		var frente_visual: Vector3 = (jugador.visual_quaternius.global_basis * Vector3.BACK).normalized()
		var blend_esperado := Vector2(direccion.x, -direccion.z).normalized()
		var blend_actual: Vector2 = arbol.get("parameters/Locomocion/blend_position")
		_check(frente_visual.dot(direccion.normalized()) > 0.97, "El Ranger mira hacia el movimiento %s" % direccion)
		_check(blend_actual.distance_to(blend_esperado) < 0.01, "El BlendSpace recibe la dirección %s" % direccion)
		_check(is_equal_approx(jugador.modelo.rotation.y, yaw_logico), "La corrección visual no cambia el yaw lógico")

	# Comprobar que Walk y la cabeza reciben una pose animada del retarget.
	var resto_muslo := esqueleto.get_bone_rest(hueso_muslo_izq).basis.orthonormalized().get_rotation_quaternion()
	jugador.en_el_aire = false
	jugador.corriendo = false
	jugador.velocity = Vector3(0.0, 0.0, -jugador.VELOCIDAD)
	await _simular_animacion(jugador, 1.0 / 60.0, 45)
	_check(resto_muslo.angle_to(esqueleto.get_bone_pose_rotation(hueso_muslo_izq)) > 0.04, "Walk anima las piernas del Ranger mediante retarget")
	_check(
		esqueleto_cabeza.get_bone_pose_rotation(cabeza_rig_base).angle_to(
			esqueleto_cabeza.get_bone_rest(cabeza_rig_base).basis.get_rotation_quaternion()
		) > 0.001,
		"La cabeza recibe las poses de la biblioteca"
	)

	jugador.corriendo = true
	jugador.velocity = Vector3(0.0, 0.0, -6.0)
	await _simular_animacion(jugador, 1.0 / 60.0, 20)
	_check(jugador.playback_animacion_quaternius.get_current_node() == &"Correr", "Jog_Fwd se activa al correr")
	jugador.velocity = Vector3(0.0, 0.0, -9.5)
	await _simular_animacion(jugador, 1.0 / 60.0, 20)
	_check(jugador.playback_animacion_quaternius.get_current_node() == &"Sprint", "Sprint se activa al alcanzar su velocidad")
	jugador.corriendo = false
	jugador.en_el_aire = true
	jugador.velocity = Vector3(0.0, jugador.SALTO, 0.0)
	jugador.tiempo_aire_animacion = 0.0
	jugador.salto_animacion_pendiente = true
	await _simular_animacion(jugador, 1.0 / 60.0, 10)
	_check(jugador.playback_animacion_quaternius.get_current_node() == &"SaltoInicio", "El despegue reproduce Jump_Start")
	await _simular_animacion(jugador, 1.0 / 60.0, 25)
	_check(jugador.playback_animacion_quaternius.get_current_node() == &"Aire", "El ascenso reproduce el ciclo Jump")
	jugador.velocity.y = -2.0
	await _simular_animacion(jugador, 1.0 / 60.0, 12)
	_check(jugador.playback_animacion_quaternius.get_current_node() == &"Caida", "El descenso activa el estado de caída")
	jugador.en_el_aire = false
	jugador.velocity.y = 0.0
	await _simular_animacion(jugador, 1.0 / 60.0, 12)
	_check(jugador.playback_animacion_quaternius.get_current_node() == &"Aterrizaje", "El contacto con el suelo reproduce Jump_Land")
	await _simular_animacion(jugador, 1.0 / 60.0, 110)
	_check(jugador.playback_animacion_quaternius.get_current_node() == &"Locomocion", "Jump_Land termina y devuelve a locomoción")
	jugador.en_el_aire = true
	jugador.velocity.y = -1.0
	jugador.estaba_en_aire_animacion = false
	jugador.tiempo_aire_animacion = 0.0
	jugador.salto_animacion_pendiente = false
	await _simular_animacion(jugador, 1.0 / 60.0, 12)
	_check(jugador.playback_animacion_quaternius.get_current_node() == &"Caida", "Caer desde un borde inicia directamente el estado de caída")

	if fallos.is_empty():
		print("[RESULTADO] Modelo completo, orientación y animaciones oficiales UAL verificadas.")
		quit(0)
	else:
		push_error("[RESULTADO] Fallaron %d comprobaciones." % fallos.size())
		quit(1)


func _simular_animacion(jugador: Node, delta: float, cuadros: int) -> void:
	for indice in range(cuadros):
		jugador._animar(delta)
		await physics_frame


func _direccion_brazo_en_modelo(datos_esqueleto: Dictionary, nombre_arriba: String, nombre_abajo: String) -> Vector3:
	var esqueleto := datos_esqueleto["esqueleto"] as Skeleton3D
	esqueleto.force_update_all_bone_transforms()
	var indice_arriba := esqueleto.find_bone(nombre_arriba)
	var indice_abajo := esqueleto.find_bone(nombre_abajo)
	var origen_arriba := esqueleto.get_bone_global_pose(indice_arriba).origin
	var origen_abajo := esqueleto.get_bone_global_pose(indice_abajo).origin
	var base_esqueleto_en_modelo: Basis = datos_esqueleto["base_esqueleto_en_modelo"]
	return (base_esqueleto_en_modelo * (origen_abajo - origen_arriba)).normalized()
