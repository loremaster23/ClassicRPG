extends SceneTree

const ServidorScript := preload("res://scripts/servidor/Servidor.gd")

func _initialize() -> void:
    var instancia = ServidorScript.new()
    instancia._inicializar_mundo()

    var entidades: Dictionary = instancia.entidades
    var correcta := entidades.size() == 2
    correcta = correcta and entidades.has(1) and entidades.has(2)

    if correcta:
        correcta = entidades[1].get("type") == "prueba"
        correcta = correcta and entidades[2].get("type") == "npc"

    if correcta:
        for id in [1, 2]:
            var entidad: Dictionary = entidades[id]
            for eje in ["x", "y", "z"]:
                if not is_finite(float(entidad[eje])):
                    correcta = false

    if correcta:
        print("OK: entidad prueba registrada con ID 1")
        print("OK: NPC registrado con ID 2")
        print("OK: coordenadas válidas")
        instancia.free()
        quit(0)
    else:
        push_error("Falló la inicialización o el registro de entidades.")
        instancia.free()
        quit(1)
