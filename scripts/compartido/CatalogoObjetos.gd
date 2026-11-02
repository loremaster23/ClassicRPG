extends RefCounted

const CAPACIDAD_RANURAS := 20

const DEFINICIONES := {
	"colmillo_lobo": {
		"nombre": "Colmillo de lobo",
		"tipo": "material",
		"max_pila": 20
	},
	"piel_lobo": {
		"nombre": "Piel de lobo",
		"tipo": "material",
		"max_pila": 10
	},
	"colmillo_jabali": {
		"nombre": "Colmillo de jabalí",
		"tipo": "material",
		"max_pila": 20
	},
	"carne_jabali": {
		"nombre": "Carne de jabalí",
		"tipo": "material",
		"max_pila": 10
	},
	"gelatina_limo": {
		"nombre": "Gelatina de limo",
		"tipo": "material",
		"max_pila": 20
	},
	"pocion_curativa": {
		"nombre": "Poción curativa",
		"tipo": "consumible",
		"max_pila": 10,
		"curacion": 35,
		"precio_compra": 20
	},
	"espada_del_habitante": {
		"nombre": "Espada del Habitante",
		"tipo": "equipo",
		"max_pila": 1,
		"ranura": "arma",
		"bono_danio": 5
	}
}


static func obtener(id_objeto: String) -> Dictionary:
	if not DEFINICIONES.has(id_objeto):
		return {}
	return DEFINICIONES[id_objeto].duplicate(true)


static func nombre(id_objeto: String) -> String:
	var definicion: Dictionary = obtener(id_objeto)
	return str(definicion.get("nombre", id_objeto))
