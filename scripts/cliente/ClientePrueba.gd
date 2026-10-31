extends Node

const DIRECCION := "ws://127.0.0.1:9000"

var cliente := WebSocketMultiplayerPeer.new()
var mensaje_enviado := false
var rechazado := false
var listo := false
var id_jugador := 0
var tiempo := 0.0
var tiempo_envio := 0.0

func _ready() -> void:
    var error := cliente.create_client(DIRECCION)

    if error != OK:
        push_error("Error al conectar: %s" % error)
        get_tree().quit()
        return

    print("Conectando con el servidor...")

func _process(delta: float) -> void:
    cliente.poll()
    tiempo += delta

    while cliente.get_available_packet_count() > 0:
        var respuesta := cliente.get_packet().get_string_from_utf8()

        if respuesta == "SERVIDOR_LLENO":
            rechazado = true
            print("RECHAZADO: el servidor está lleno.")
            cliente.close()
            get_tree().quit()
            return

        var datos = JSON.parse_string(respuesta)

        if typeof(datos) != TYPE_DICTIONARY:
            continue

        match datos.get("type", ""):
            "welcome":
                id_jugador = int(datos.get("id", 0))
                listo = true
                print("Conectado. Mi ID es: ", id_jugador)
                print("Jugadores ya conectados: ", datos.get("players", []).size())

            "player_joined":
                print("Nuevo jugador conectado. ID: ", datos.get("id", 0))

            "player_left":
                print("Jugador desconectado. ID: ", datos.get("id", 0))

            "move":
                print("Movimiento recibido del jugador: ", datos.get("id", 0))

    var estado := cliente.get_connection_status()

    if estado == MultiplayerPeer.CONNECTION_CONNECTED and not mensaje_enviado:
        print("Conexión WebSocket establecida. Esperando identificación.")
        mensaje_enviado = true

    if listo:
        tiempo_envio += delta

        if tiempo_envio >= 0.1:
            tiempo_envio = 0.0

            var movimiento := {
                "type": "move",
                "x": float(id_jugador % 10),
                "y": 0.6,
                "z": 10.0,
                "yaw": 0.0
            }

            cliente.put_packet(JSON.stringify(movimiento).to_utf8_buffer())

    if estado == MultiplayerPeer.CONNECTION_DISCONNECTED and tiempo > 10.0 and not rechazado:
        push_error("No se pudo mantener la conexión.")
        get_tree().quit()

    if listo and tiempo > 60.0:
        print("Finalizando cliente de prueba.")
        cliente.close()
        get_tree().quit()

func _exit_tree() -> void:
    cliente.close()
