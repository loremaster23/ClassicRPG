extends Node

const PUERTO := 9000
const MAX_JUGADORES := 2

var servidor := WebSocketMultiplayerPeer.new()
var jugadores := 0

func _ready() -> void:
    servidor.peer_connected.connect(_al_conectar)
    servidor.peer_disconnected.connect(_al_desconectar)

    var error := servidor.create_server(PUERTO, "*")

    if error != OK:
        push_error("No se pudo iniciar el servidor: %s" % error)
        return

    print("Servidor iniciado. Máximo de jugadores: ", MAX_JUGADORES)

func _process(_delta: float) -> void:
    servidor.poll()

    while servidor.get_available_packet_count() > 0:
        var id := servidor.get_packet_peer()
        var mensaje := servidor.get_packet()
        print("Jugador ", id, ": ", mensaje.get_string_from_utf8())

func _al_conectar(id: int) -> void:
    jugadores += 1
    print("Jugador conectado: ", id, " | ", jugadores, "/", MAX_JUGADORES)

    if jugadores >= MAX_JUGADORES:
        servidor.refuse_new_connections = true
        print("Servidor lleno. No acepta más conexiones.")

func _al_desconectar(id: int) -> void:
    jugadores -= 1
    print("Jugador desconectado: ", id, " | ", jugadores, "/", MAX_JUGADORES)
    servidor.refuse_new_connections = false

func _exit_tree() -> void:
    servidor.close()