extends Node

const DIRECCION := "ws://127.0.0.1:9000"
const EscenaJugador := preload("res://Personajes/Jugador.tscn")

var cliente := WebSocketMultiplayerPeer.new()
var jugador_local: CharacterBody3D
var id_local := 0
var conectado := false
var tiempo_envio := 0.0

var jugadores_remotos: Dictionary = {}
var objetivos_remotos: Dictionary = {}

func iniciar(jugador: CharacterBody3D) -> void:
    jugador_local = jugador

    var error := cliente.create_client(DIRECCION)

    if error != OK:
        push_error("Error al conectar con el servidor: %s" % error)
        return

    print("Conectando al servidor multijugador...")

func _process(delta: float) -> void:
    cliente.poll()

    while cliente.get_available_packet_count() > 0:
        var mensaje := cliente.get_packet().get_string_from_utf8()
        var datos = JSON.parse_string(mensaje)

        if typeof(datos) != TYPE_DICTIONARY:
            continue

        _procesar_mensaje(datos)

    if cliente.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
        if not conectado:
            conectado = true
            print("Conexión multijugador establecida.")

        if id_local != 0:
            tiempo_envio += delta

            if tiempo_envio >= 0.1:
                tiempo_envio = 0.0
                _enviar_posicion()

    _actualizar_remotos(delta)

func _procesar_mensaje(datos: Dictionary) -> void:
    match datos.get("type", ""):
        "welcome":
            id_local = int(datos.get("id", 0))
            print("Identificado en el servidor. ID: ", id_local)

            for jugador in datos.get("players", []):
                if typeof(jugador) == TYPE_DICTIONARY:
                    _crear_remoto(
                        int(jugador.get("id", 0)),
                        _leer_posicion(jugador),
                        float(jugador.get("yaw", 0.0)), bool(jugador.get("sprint", false))
                    )

        "player_joined":
            var id := int(datos.get("id", 0))
            print("Jugador conectado: ", id)

            _crear_remoto(
                id,
                _leer_posicion(datos),
                float(datos.get("yaw", 0.0)), bool(datos.get("sprint", false))
            )

        "move":
            var id := int(datos.get("id", 0))

            if id != id_local and jugadores_remotos.has(id):
                _actualizar_objetivo(
                    id,
                    _leer_posicion(datos),
                    float(datos.get("yaw", 0.0)), bool(datos.get("sprint", false))
                )

        "player_left":
            var id := int(datos.get("id", 0))
            _eliminar_remoto(id)
            print("Jugador desconectado: ", id)

func _leer_posicion(datos: Dictionary) -> Vector3:
    return Vector3(
        float(datos.get("x", 0.0)),
        float(datos.get("y", 0.6)),
        float(datos.get("z", 10.0))
    )

func _crear_remoto(id: int, posicion: Vector3, yaw: float, sprint: bool = false) -> void:
    if id == 0 or id == id_local or jugadores_remotos.has(id):
        return

    var remoto = EscenaJugador.instantiate()
    remoto.es_local = false
    get_parent().add_child(remoto)

    remoto.global_position = posicion
    remoto.set_physics_process(false)

    var colision := remoto.get_node_or_null("Colision") as CollisionShape3D

    if colision:
        colision.set_deferred("disabled", true)

    remoto.get_node("Modelo").rotation.y = yaw

    jugadores_remotos[id] = remoto
    objetivos_remotos[id] = {
        "pos": posicion,
        "yaw": yaw,
        "sprint": sprint
    }

    print("Personaje remoto creado: ", id)

func _actualizar_objetivo(id: int, posicion: Vector3, yaw: float, sprint: bool) -> void:
    objetivos_remotos[id] = {
        "pos": posicion,
        "yaw": yaw,
        "sprint": sprint
    }

func _actualizar_remotos(delta: float) -> void:
    for id_var in jugadores_remotos.keys():
        var id := int(id_var)
        var remoto = jugadores_remotos[id]

        if not is_instance_valid(remoto):
            continue

        if not objetivos_remotos.has(id):
            continue

        var objetivo: Dictionary = objetivos_remotos[id]
        remoto.corriendo = bool(objetivo.get("sprint", false))
        var anterior: Vector3 = remoto.global_position

        remoto.global_position = remoto.global_position.lerp(
            objetivo["pos"],
            minf(delta * 12.0, 1.0)
        )

        remoto.velocity = (remoto.global_position - anterior) / maxf(delta, 0.0001)

        var modelo: Node3D = remoto.get_node("Modelo")
        modelo.rotation.y = lerp_angle(
            modelo.rotation.y,
            float(objetivo["yaw"]),
            minf(delta * 12.0, 1.0)
        )


        remoto.call("_animar", delta)

func _enviar_posicion() -> void:
    if not is_instance_valid(jugador_local):
        return

    var posicion := jugador_local.global_position
    var modelo: Node3D = jugador_local.get_node("Modelo")

    var paquete := {
        "type": "move",
        "x": posicion.x,
        "y": posicion.y,
        "z": posicion.z,
        "yaw": modelo.rotation.y,
        "sprint": jugador_local.corriendo
    }

    var error := cliente.put_packet(JSON.stringify(paquete).to_utf8_buffer())

    if error != OK:
        push_error("Error enviando posición al servidor: %s" % error)

func _eliminar_remoto(id: int) -> void:
    if jugadores_remotos.has(id):
        var remoto = jugadores_remotos[id]

        if is_instance_valid(remoto):
            remoto.queue_free()

        jugadores_remotos.erase(id)

    objetivos_remotos.erase(id)

func _exit_tree() -> void:
    cliente.close()
