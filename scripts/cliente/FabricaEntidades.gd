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