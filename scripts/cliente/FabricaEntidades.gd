extends RefCounted

## Crea representaciones visuales para entidades remotas.
static func crear(tipo: String, id: int, nombre: String = "") -> Node3D:
	if id <= 0:
		return null

	var entidad := Node3D.new()
	entidad.name = "EntidadRemota_%d" % id

	match tipo:
		"prueba":
			var esfera := SphereMesh.new()
			esfera.radius = 0.45
			esfera.height = 0.9

			var material := StandardMaterial3D.new()
			material.albedo_color = Color(0.2, 0.8, 1.0, 1.0)
			material.metallic = 0.3
			material.roughness = 0.25
			material.emission_enabled = true
			material.emission = Color(0.1, 0.5, 0.8, 1.0)

			entidad.add_child(_crear_malla(esfera, material, "Malla"))

		"npc":
			var material_cuerpo := StandardMaterial3D.new()
			material_cuerpo.albedo_color = Color(0.25, 0.65, 0.3, 1.0)
			material_cuerpo.roughness = 0.85

			var cuerpo := CapsuleMesh.new()
			cuerpo.radius = 0.35
			cuerpo.height = 1.3
			var malla_cuerpo := _crear_malla(cuerpo, material_cuerpo, "Cuerpo")
			malla_cuerpo.position.y = 0.65
			entidad.add_child(malla_cuerpo)

			var cabeza := SphereMesh.new()
			cabeza.radius = 0.22
			cabeza.height = 0.44
			var material_cabeza := StandardMaterial3D.new()
			material_cabeza.albedo_color = Color(0.85, 0.68, 0.5, 1.0)
			var malla_cabeza := _crear_malla(cabeza, material_cabeza, "Cabeza")
			malla_cabeza.position.y = 1.45
			entidad.add_child(malla_cabeza)

			if not nombre.is_empty():
				var etiqueta := Label3D.new()
				etiqueta.name = "Nombre"
				etiqueta.text = nombre
				etiqueta.position.y = 2.0
				etiqueta.billboard = BaseMaterial3D.BILLBOARD_ENABLED
				etiqueta.font_size = 32
				etiqueta.outline_size = 8
				entidad.add_child(etiqueta)

		"lobo":
			var material_lobo := StandardMaterial3D.new()
			material_lobo.albedo_color = Color(0.42, 0.26, 0.18, 1.0)
			material_lobo.roughness = 0.85

			var cuerpo := BoxMesh.new()
			cuerpo.size = Vector3(0.7, 0.6, 1.2)
			var malla_cuerpo := _crear_malla(cuerpo, material_lobo, "Cuerpo")
			malla_cuerpo.position.y = 0.55
			entidad.add_child(malla_cuerpo)

			var cabeza := BoxMesh.new()
			cabeza.size = Vector3(0.45, 0.45, 0.5)
			var malla_cabeza := _crear_malla(cabeza, material_lobo, "Cabeza")
			malla_cabeza.position = Vector3(0.0, 0.75, -0.7)
			entidad.add_child(malla_cabeza)

			var pata_mesh := BoxMesh.new()
			pata_mesh.size = Vector3(0.18, 0.5, 0.18)
			var pos_patas := [
				Vector3(-0.25, 0.25, 0.4),
				Vector3(0.25, 0.25, 0.4),
				Vector3(-0.25, 0.25, -0.4),
				Vector3(0.25, 0.25, -0.4)
			]
			for i in range(pos_patas.size()):
				var pata := _crear_malla(pata_mesh, material_lobo, "Pata_%d" % i)
				pata.position = pos_patas[i]
				entidad.add_child(pata)

			if not nombre.is_empty():
				var etiqueta := Label3D.new()
				etiqueta.name = "Nombre"
				etiqueta.text = nombre
				etiqueta.position.y = 1.5
				etiqueta.billboard = BaseMaterial3D.BILLBOARD_ENABLED
				etiqueta.font_size = 32
				etiqueta.outline_size = 8
				etiqueta.modulate = Color(1.0, 0.35, 0.35, 1.0)
				entidad.add_child(etiqueta)

		"jabali":
			var material_jabali := StandardMaterial3D.new()
			material_jabali.albedo_color = Color(0.34, 0.22, 0.13, 1.0)
			material_jabali.roughness = 0.9
			var material_colmillos := StandardMaterial3D.new()
			material_colmillos.albedo_color = Color(0.92, 0.82, 0.62, 1.0)
			material_colmillos.roughness = 0.65

			var cuerpo := SphereMesh.new()
			cuerpo.radius = 0.58
			cuerpo.height = 0.95
			var malla_cuerpo := _crear_malla(cuerpo, material_jabali, "Cuerpo")
			malla_cuerpo.position.y = 0.58
			malla_cuerpo.scale = Vector3(1.2, 0.9, 1.35)
			entidad.add_child(malla_cuerpo)

			var cabeza := SphereMesh.new()
			cabeza.radius = 0.34
			cabeza.height = 0.68
			var malla_cabeza := _crear_malla(cabeza, material_jabali, "Cabeza")
			malla_cabeza.position = Vector3(0.0, 0.72, -0.58)
			malla_cabeza.scale = Vector3(1.0, 0.9, 1.1)
			entidad.add_child(malla_cabeza)

			var hocico := SphereMesh.new()
			hocico.radius = 0.22
			hocico.height = 0.34
			var malla_hocico := _crear_malla(hocico, material_jabali, "Hocico")
			malla_hocico.position = Vector3(0.0, 0.63, -0.9)
			malla_hocico.scale = Vector3(1.15, 0.75, 0.8)
			entidad.add_child(malla_hocico)

			var colmillo := CylinderMesh.new()
			colmillo.top_radius = 0.02
			colmillo.bottom_radius = 0.075
			colmillo.height = 0.28
			for lado in [-1.0, 1.0]:
				var malla_colmillo := _crear_malla(colmillo, material_colmillos, "Colmillo")
				malla_colmillo.position = Vector3(0.22 * lado, 0.67, -0.81)
				malla_colmillo.rotation.x = -PI * 0.5
				entidad.add_child(malla_colmillo)

			var pata := CylinderMesh.new()
			pata.top_radius = 0.075
			pata.bottom_radius = 0.11
			pata.height = 0.38
			var posiciones_patas := [
				Vector3(-0.3, 0.19, 0.34),
				Vector3(0.3, 0.19, 0.34),
				Vector3(-0.3, 0.19, -0.34),
				Vector3(0.3, 0.19, -0.34)
			]
			for i in range(posiciones_patas.size()):
				var malla_pata := _crear_malla(pata, material_jabali, "Pata_%d" % i)
				malla_pata.position = posiciones_patas[i]
				entidad.add_child(malla_pata)

			if not nombre.is_empty():
				var etiqueta := Label3D.new()
				etiqueta.name = "Nombre"
				etiqueta.text = nombre
				etiqueta.position.y = 1.45
				etiqueta.billboard = BaseMaterial3D.BILLBOARD_ENABLED
				etiqueta.font_size = 32
				etiqueta.outline_size = 8
				etiqueta.modulate = Color(0.95, 0.68, 0.38, 1.0)
				entidad.add_child(etiqueta)

		"limo":
			var material_limo := StandardMaterial3D.new()
			material_limo.albedo_color = Color(0.25, 0.72, 0.38, 1.0)
			material_limo.roughness = 0.35
			material_limo.metallic = 0.05
			material_limo.emission_enabled = true
			material_limo.emission = Color(0.08, 0.28, 0.1, 1.0)

			var cuerpo := SphereMesh.new()
			cuerpo.radius = 0.52
			cuerpo.height = 0.9
			cuerpo.radial_segments = 10
			cuerpo.rings = 5
			var malla_cuerpo := _crear_malla(cuerpo, material_limo, "Cuerpo")
			malla_cuerpo.position.y = 0.48
			malla_cuerpo.scale = Vector3(1.1, 0.9, 1.0)
			entidad.add_child(malla_cuerpo)

			var material_ojos := StandardMaterial3D.new()
			material_ojos.albedo_color = Color(0.08, 0.07, 0.04, 1.0)
			var ojo := SphereMesh.new()
			ojo.radius = 0.07
			ojo.height = 0.14
			for lado in [-1.0, 1.0]:
				var malla_ojo := _crear_malla(ojo, material_ojos, "Ojo")
				malla_ojo.position = Vector3(0.17 * lado, 0.62, -0.39)
				entidad.add_child(malla_ojo)

			if not nombre.is_empty():
				var etiqueta := Label3D.new()
				etiqueta.name = "Nombre"
				etiqueta.text = nombre
				etiqueta.position.y = 1.2
				etiqueta.billboard = BaseMaterial3D.BILLBOARD_ENABLED
				etiqueta.font_size = 32
				etiqueta.outline_size = 8
				etiqueta.modulate = Color(0.55, 1.0, 0.62, 1.0)
				entidad.add_child(etiqueta)

		_:
			entidad.free()
			return null

	return entidad


static func _crear_malla(malla: Mesh, material: Material, nombre: String) -> MeshInstance3D:
	var instancia := MeshInstance3D.new()
	instancia.name = nombre
	instancia.mesh = malla
	instancia.material_override = material
	return instancia
