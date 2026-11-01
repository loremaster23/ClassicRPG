
import bpy
from mathutils import Vector

# ============================================================
# CLASSICRPG - CABALLERO MEDIEVAL
# Blender 5.2.3
# Generador independiente para Godot
# ============================================================

CARPETA = bpy.path.abspath("//")
NOMBRE = "Caballero"

# ------------------------------------------------------------
# LIMPIEZA
# ------------------------------------------------------------

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)

# ------------------------------------------------------------
# MATERIALES
# ------------------------------------------------------------

def material(nombre, color, metal=0.0, rough=0.45):
    mat = bpy.data.materials.new(nombre)
    mat.diffuse_color = (*color, 1.0)
    mat.use_nodes = True

    nodes = mat.node_tree.nodes
    links = mat.node_tree.links
    nodes.clear()

    bsdf = nodes.new("ShaderNodeBsdfPrincipled")
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Metallic"].default_value = metal
    bsdf.inputs["Roughness"].default_value = rough

    output = nodes.new("ShaderNodeOutputMaterial")
    links.new(bsdf.outputs["BSDF"], output.inputs["Surface"])

    return mat


acero = material("Acero azul oscuro", (0.075, 0.13, 0.23), 0.78, 0.3)
acero_claro = material("Acero pulido", (0.38, 0.48, 0.58), 0.85, 0.24)
oro = material("Detalles dorados", (0.72, 0.43, 0.09), 0.72, 0.28)
cuero = material("Cuero marron", (0.16, 0.065, 0.025), 0.05, 0.72)
tela = material("Capa carmesi", (0.32, 0.018, 0.035), 0.0, 0.85)
tela_oscura = material("Interior capa", (0.12, 0.008, 0.018), 0.0, 0.9)
negro = material("Ranuras oscuras", (0.012, 0.016, 0.022), 0.15, 0.5)
piel = material("Piel", (0.48, 0.28, 0.17), 0.0, 0.8)

# ------------------------------------------------------------
# FUNCIONES
# Blender: Z arriba. Personaje mirando hacia -Y.
# ------------------------------------------------------------

def asignar(obj, mat):
    obj.data.materials.append(mat)
    return obj


def cubo(nombre, loc, escala, mat, bevel=0.04):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    obj = bpy.context.object
    obj.name = nombre
    obj.dimensions = escala

    bpy.ops.object.transform_apply(
        location=False,
        rotation=False,
        scale=True
    )

    asignar(obj, mat)

    if bevel > 0:
        mod = obj.modifiers.new("Bordes biselados", "BEVEL")
        mod.width = bevel
        mod.segments = 1

        mod2 = obj.modifiers.new("Normales", "WEIGHTED_NORMAL")
        mod2.keep_sharp = True

    return obj


def esfera(nombre, loc, escala, mat, segmentos=12, anillos=8):
    bpy.ops.mesh.primitive_uv_sphere_add(
        segments=segmentos,
        ring_count=anillos,
        radius=1,
        location=loc
    )

    obj = bpy.context.object
    obj.name = nombre
    obj.scale = escala

    bpy.ops.object.transform_apply(
        location=False,
        rotation=False,
        scale=True
    )

    asignar(obj, mat)

    for polygon in obj.data.polygons:
        polygon.use_smooth = False

    return obj


def cilindro(nombre, loc, radio, profundidad, mat, vertices=10, rot=None):
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=vertices,
        radius=radio,
        depth=profundidad,
        location=loc
    )

    obj = bpy.context.object
    obj.name = nombre

    if rot:
        obj.rotation_euler = rot

    asignar(obj, mat)

    for polygon in obj.data.polygons:
        polygon.use_smooth = False

    return obj


def barra(nombre, inicio, fin, radio, mat, vertices=8):
    a = Vector(inicio)
    b = Vector(fin)
    direccion = b - a
    centro = (a + b) / 2

    bpy.ops.mesh.primitive_cylinder_add(
        vertices=vertices,
        radius=radio,
        depth=direccion.length,
        location=centro
    )

    obj = bpy.context.object
    obj.name = nombre
    obj.rotation_mode = "QUATERNION"
    obj.rotation_quaternion = direccion.to_track_quat("Z", "Y")

    asignar(obj, mat)

    for polygon in obj.data.polygons:
        polygon.use_smooth = False

    return obj


# ------------------------------------------------------------
# BOTAS Y PIERNAS
# ------------------------------------------------------------

for lado, x in (("Izquierda", -0.23), ("Derecha", 0.23)):
    cubo("Bota_" + lado, (x, -0.07, 0.13), (0.30, 0.48, 0.25), cuero)
    cubo("Puntera_" + lado, (x, -0.19, 0.22), (0.29, 0.23, 0.12), acero)
    cubo("Greba_" + lado, (x, -0.015, 0.48), (0.29, 0.29, 0.53), acero)
    cubo("Borde_Greba_" + lado, (x, -0.17, 0.68), (0.31, 0.045, 0.055), oro, 0.015)
    cubo("Rodillera_" + lado, (x, -0.18, 0.79), (0.32, 0.16, 0.19), acero_claro)
    esfera("Remache_Rodilla_" + lado, (x, -0.27, 0.79), (0.045, 0.025, 0.045), oro, 8, 6)
    cubo("Muslera_" + lado, (x, 0, 0.98), (0.34, 0.36, 0.34), acero)

# ------------------------------------------------------------
# CINTURON
# ------------------------------------------------------------

cubo("Cinturon", (0, -0.005, 1.13), (0.76, 0.43, 0.12), cuero)
cubo("Hebilla", (0, -0.235, 1.13), (0.16, 0.045, 0.13), oro, 0.02)
cubo("Centro_Hebilla", (0, -0.263, 1.13), (0.075, 0.018, 0.065), acero)

# ------------------------------------------------------------
# TORSO Y PECHERA
# ------------------------------------------------------------

cubo("Torso_Armadura", (0, 0, 1.48), (0.83, 0.47, 0.67), acero)
cubo("Pechera_Central", (0, -0.25, 1.49), (0.57, 0.075, 0.52), acero_claro)
cubo("Placa_Esternal", (0, -0.296, 1.52), (0.28, 0.025, 0.36), acero)
cubo("Borde_Pecho_Superior", (0, -0.30, 1.79), (0.64, 0.055, 0.065), oro)
cubo("Borde_Pecho_Inferior", (0, -0.30, 1.22), (0.62, 0.055, 0.055), oro)

esfera("Emblema_Pecho", (0, -0.326, 1.53), (0.105, 0.035, 0.13), oro, 8, 6)
esfera("Gema_Emblema", (0, -0.358, 1.54), (0.055, 0.018, 0.075), tela, 8, 6)

for i in range(3):
    z = 1.29 - i * 0.105
    cubo(
        "Placa_Abdominal_" + str(i),
        (0, -0.275, z),
        (0.55 - i * 0.025, 0.045, 0.075),
        acero_claro,
        0.015
    )

# ------------------------------------------------------------
# HOMBROS Y BRAZOS
# ------------------------------------------------------------

for lado, x in (("Izquierda", -0.55), ("Derecha", 0.55)):
    esfera("Hombrera_" + lado, (x, 0, 1.81), (0.29, 0.34, 0.23), acero, 10, 6)
    esfera("Placa_Hombrera_" + lado, (x, -0.22, 1.84), (0.22, 0.12, 0.16), acero_claro, 10, 6)
    esfera("Remache_Hombro_" + lado, (x, -0.325, 1.85), (0.055, 0.025, 0.055), oro, 8, 6)

    barra("Brazo_" + lado, (x, 0, 1.72), (x * 1.12, 0, 1.25), 0.115, acero)
    cilindro("Codo_" + lado, (x * 1.12, 0, 1.25), 0.13, 0.12, acero_claro, 8)
    barra("Antebrazo_" + lado, (x * 1.12, 0, 1.24), (x * 1.18, -0.015, 0.99), 0.105, acero_claro)
    cilindro("Guantelete_" + lado, (x * 1.18, -0.015, 0.99), 0.12, 0.17, acero, 8)
    esfera("Mano_" + lado, (x * 1.18, -0.025, 0.86), (0.105, 0.10, 0.12), cuero, 8, 6)

# ------------------------------------------------------------
# CASCO
# ------------------------------------------------------------

esfera("Casco_Base", (0, 0, 2.04), (0.29, 0.29, 0.34), acero_claro, 12, 8)
cubo("Visera", (0, -0.25, 2.06), (0.42, 0.12, 0.10), acero)
cubo("Protector_Cara", (0, -0.255, 1.94), (0.34, 0.10, 0.19), acero)
cubo("Ranura_Visor", (0, -0.313, 2.00), (0.23, 0.018, 0.035), negro)
cubo("Protector_Nasal", (0, -0.32, 1.96), (0.055, 0.055, 0.23), oro)
cubo("Borde_Casco", (0, -0.10, 2.29), (0.49, 0.36, 0.045), oro, 0.015)

barra("Cresta_Casco", (0, 0, 2.30), (0, 0, 2.48), 0.045, oro, 6)

for x in (-0.27, 0.27):
    cubo("Protector_Lateral", (x, -0.02, 1.91), (0.07, 0.20, 0.30), acero)

# ------------------------------------------------------------
# CAPA
# ------------------------------------------------------------

vertices = [
    (-0.35, 0.20, 1.78),
    (0.35, 0.20, 1.78),
    (-0.53, 0.42, 0.34),
    (0.53, 0.42, 0.34),
    (-0.28, 0.55, 0.38),
    (0.28, 0.55, 0.38),
]

caras = [
    (0, 1, 3, 2),
    (2, 3, 5, 4),
]

mesh = bpy.data.meshes.new("Malla_Capa")
mesh.from_pydata(vertices, [], caras)
mesh.materials.append(tela)
mesh.materials.append(tela_oscura)

capa = bpy.data.objects.new("Capa_Carmesi", mesh)
bpy.context.collection.objects.link(capa)

capa.data.polygons[0].material_index = 0
capa.data.polygons[1].material_index = 1

solid = capa.modifiers.new("Grosor de tela", "SOLIDIFY")
solid.thickness = 0.025

for x in (-0.28, 0.28):
    esfera("Broche_Capa", (x, 0.18, 1.79), (0.07, 0.045, 0.07), oro, 8, 6)

# ------------------------------------------------------------
# ESPADA
# ------------------------------------------------------------

x_espada = 0.73

barra("Hoja_Espada", (x_espada, -0.10, 0.91), (x_espada, -0.10, 1.78), 0.045, acero_claro, 4)
barra("Filo_Espada", (x_espada + 0.035, -0.10, 0.98), (x_espada + 0.035, -0.10, 1.72), 0.012, acero, 4)
barra("Guarda_Espada", (x_espada - 0.18, -0.10, 0.91), (x_espada + 0.18, -0.10, 0.91), 0.035, oro, 6)
barra("Mango_Espada", (x_espada, -0.10, 0.68), (x_espada, -0.10, 0.88), 0.035, cuero, 6)
esfera("Pomo_Espada", (x_espada, -0.10, 0.65), (0.065, 0.065, 0.065), oro, 8, 6)
esfera("Punta_Espada", (x_espada, -0.10, 1.79), (0.035, 0.035, 0.055), acero_claro, 6, 4)

# ------------------------------------------------------------
# ESCUDO
# ------------------------------------------------------------

esfera("Escudo_Acero", (-0.77, -0.13, 1.23), (0.32, 0.095, 0.47), acero, 10, 8)
esfera("Centro_Escudo", (-0.77, -0.235, 1.23), (0.19, 0.045, 0.27), oro, 8, 6)
esfera("Emblema_Escudo", (-0.77, -0.28, 1.23), (0.105, 0.035, 0.16), tela, 8, 6)

for dx, dz in ((-0.20, 0), (0.20, 0), (0, 0.34), (0, -0.34)):
    esfera(
        "Remache_Escudo",
        (-0.77 + dx, -0.24, 1.23 + dz),
        (0.035, 0.025, 0.035),
        acero_claro,
        8,
        6
    )

# ------------------------------------------------------------
# ORGANIZACION
# ------------------------------------------------------------

coleccion = bpy.data.collections.new("CLASSICRPG_CABALLERO")
bpy.context.scene.collection.children.link(coleccion)

for obj in list(bpy.context.scene.objects):
    for col in list(obj.users_collection):
        col.objects.unlink(obj)
    coleccion.objects.link(obj)

bpy.context.scene.unit_settings.system = "METRIC"
bpy.context.scene.unit_settings.scale_length = 1.0

# Seleccionar todos los objetos del caballero
bpy.ops.object.select_all(action="DESELECT")

for obj in coleccion.objects:
    obj.select_set(True)

bpy.context.view_layer.objects.active = next(iter(coleccion.objects))

# ------------------------------------------------------------
# GUARDAR Y EXPORTAR
# ------------------------------------------------------------

ruta_blend = CARPETA + NOMBRE + ".blend"
ruta_glb = CARPETA + NOMBRE + ".glb"

bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

bpy.ops.export_scene.gltf(
    filepath=ruta_glb,
    export_format="GLB",
    use_selection=True,
    export_apply=True
)

print("========================================")
print("CLASSICRPG - CABALLERO GENERADO")
print("BLEND:", ruta_blend)
print("GLB:", ruta_glb)
print("OBJETOS:", len(coleccion.objects))
print("========================================")
