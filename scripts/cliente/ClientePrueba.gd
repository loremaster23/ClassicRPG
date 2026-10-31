extends Node

const DIRECCION := "ws://127.0.0.1:9000"

var cliente := WebSocketMultiplayerPeer.new()
var mensaje_enviado := false
var tiempo := 0.0

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

    var estado := cliente.get_connection_status()

    if estado == MultiplayerPeer.CONNECTION_CONNECTED and not mensaje_enviado:
        var error := cliente.put_packet("Hola desde el cliente".to_utf8_buffer())

        if error == OK:
            print("Conectado. Mensaje enviado correctamente.")
            mensaje_enviado = true

    if estado == MultiplayerPeer.CONNECTION_DISCONNECTED and tiempo > 10.0:
        push_error("No se pudo mantener la conexión.")
        get_tree().quit()

    if mensaje_enviado and tiempo > 60.0:
        print("Finalizando cliente de prueba.")
        cliente.close()
        get_tree().quit()

func _exit_tree() -> void:
    cliente.close()