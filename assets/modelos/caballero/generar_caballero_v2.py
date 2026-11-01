
import bpy
import math
import os
from mathutils import Vector

# ============================================================
# CLASSICRPG - CABALLERO V2
# Blender 5.2.3
# Modelo independiente, geometria editable y exportacion GLB
# ============================================================

CARPETA = os.path.dirname(os.path.abspath(__file__))
NOMBRE = "Caballero_v2"

# ------------------------------------------------------------
# LIMPIEZA DE ESCENA
# ------------------------------------------------------------

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)

for datablocks in (bpy.data.meshes, bpy.data.curves):
    for datablock in list(datablocks):
        if datablock.users == 0:
            datablocks.remove(datablock)

# ------------------------------------------------------------
# MATERIALES
# ------------------------------------------------------------

def material(nombre, color, metal=0.0, rough=0.4):
    mat = bpy.data.materials.new(nombre)
    mat.diffuse_color = (*color, 1)
    mat.use_nodes = True

    nodes = mat.node_tree.nodes
    nodes.clear()

    shader = nodes.new("ShaderNodeBsdfPrincipled")
    shader.inputs["Base Color"].default_value = (*color, 1)
    shader.inputs["Metallic"].default_value = metal
    shader.inputs["Roughness"].default_value = rough

    output = nodes.new("ShaderNodeOutputMaterial")
    mat.node_tree.links.new(
        shader.outputs["BSDF"],
        output.inputs["Surface"]
    )
    return mat


AZUL = material("Acero azul real", (0.045, 0.095, 0.19), 0.78, 0.29)
AZUL2 = material("Acero iluminado", (0.16, 0.25, 0.39), 0.82, 0.25)
AZUL_OSCURO = material("Acero oscuro", (0.018, 0.035, 0.075), 0.72, 0.34)
ORO = material("Oro imperial", (0.83, 0.48, 0.095), 0.78, 0.25)
ORO_CLARO = material("Oro pulido", (1.0, 0.72, 0.25), 0.8, 0.2)
CUERO = material("Cuero marron", (0.12, 0.045, 0.018), 0.05, 0.72)
CUERO2 = material("Cuero oscuro", (0.045, 0.022, 0.015), 0.0, 0.82)
ROJO = material("Capa carmesi", (0.31, 0.012, 0.028), 0.0, 0.85)
ROJO2 = material("Pliegues de capa", (0.12, 0.004, 0.012), 0.0, 0.9)
AZUL_TELA = material("Tabardo azul", (0.025, 0.075, 0.18), 0.0, 0.9)
NEGRO = material("Huecos y visor", (0.004, 0.008, 0.014), 0.1, 0.4)
ACERO = material("Filo de acero", (0.55, 0.65, 0.73), 0.9, 0.2)

# ------------------------------------------------------------
# FUNCIONES DE MODELADO
# Eje Z vertical. Personaje mirando hacia -Y.
# ------------------------------------------------------------

def asignar(obj, mat):
    obj.data.materials.append(mat)
    return obj


def bisel(obj, ancho=0.04, segmentos=2):
    mod = obj.modifiers.new("Bordes trabajados", "BEVEL")
    mod.width = ancho
    mod.segments = segmentos
    mod2 = obj.modifiers.new("Normales", "WEIGHTED_NORMAL")
    mod2.keep_sharp = True
    return obj


def cubo(nombre, loc, escala, mat, bevel=0.04):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    obj = bpy.context.object
    obj.name = nombre
    obj.dimensions = escala
    bpy.ops.object.transform_apply(
        location=False, rotation=False, scale=True
    )
    asignar(obj, mat)
    if bevel:
        bisel(obj, bevel)
    return obj


def esfera(nombre, loc, escala, mat, vertices=12):
    bpy.ops.mesh.primitive_uv_sphere_add(
        segments=vertices,
        ring_count=max(6, vertices // 2),
        radius=1,
        location=loc
    )
    obj = bpy.context.object
    obj.name = nombre
    obj.scale = escala
    bpy.ops.object.transform_apply(
        location=False, rotation=False, scale=True
    )
    asignar(obj, mat)
    for p in obj.data.polygons:
        p.use_smooth = False
    return obj


def cilindro(nombre, loc, radio, profundidad, mat,
             vertices=12, rot=None):
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
    bisel(obj, 0.012, 1)
    return obj


def barra(nombre, inicio, fin, radio, mat, vertices=10):
    a = Vector(inicio)
    b = Vector(fin)
    direccion = b - a

    bpy.ops.mesh.primitive_cylinder_add(
        vertices=vertices,
        radius=radio,
        depth=direccion.length,
        location=(a + b) / 2
    )
    obj = bpy.context.object
    obj.name = nombre
    obj.rotation_mode = "QUATERNION"
    obj.rotation_quaternion = direccion.to_track_quat("Z", "Y")
    asignar(obj, mat)
    bisel(obj, 0.008, 1)
    return obj


def malla(nombre, vertices, caras, mat, bevel=0):
    mesh = bpy.data.meshes.new(nombre + "_Mesh")
    mesh.from_pydata(vertices, [], caras)
    mesh.materials.append(mat)
    mesh.update()

    obj = bpy.data.objects.new(nombre, mesh)
    bpy.context.collection.objects.link(obj)

    if bevel:
        bisel(obj, bevel, 2)

    return obj


def placa(nombre, puntos, frente_y, grosor, mat):
    """Placa extruida desde un contorno visto de frente."""
    vertices = [(x, frente_y, z) for x, z in puntos]
    vertices += [(x, frente_y + grosor, z) for x, z in puntos]

    n = len(puntos)
    caras = []

    caras.append(tuple(range(n)))
    caras.append(tuple(range(n, 2*n)))

    for i in range(n):
        j = (i + 1) % n
        caras.append((i, j, j+n, i+n))

    obj = malla(nombre, vertices, caras, mat, 0.025)
    return obj


# ------------------------------------------------------------
# PIERNAS Y BOTAS
# ------------------------------------------------------------

for lado, x in (("Izquierda", -0.25), ("Derecha", 0.25)):

    # Botas robustas
    cubo("Bota_" + lado, (x, -0.075, 0.13),
         (0.39, 0.52, 0.25), CUERO, 0.075)

    cubo("Puntera_acorazada_" + lado, (x, -0.23, 0.22),
         (0.37, 0.25, 0.13), AZUL2, 0.055)

    cubo("Borde_bota_" + lado, (x, -0.22, 0.30),
         (0.38, 0.09, 0.045), ORO, 0.015)

    # Grebas delanteras
    placa("Greba_" + lado, [
        (x-0.17, 0.31),
        (x+0.17, 0.31),
        (x+0.15, 0.67),
        (x+0.09, 0.76),
        (x-0.09, 0.76),
        (x-0.15, 0.67)
    ], -0.205, 0.12, AZUL)

    cubo("Borde_greba_" + lado, (x, -0.27, 0.66),
         (0.34, 0.055, 0.055), ORO, 0.015)

    esfera("Rodillera_" + lado, (x, -0.23, 0.82),
           (0.19, 0.10, 0.17), AZUL2, 10)

    esfera("Remache_rodilla_" + lado, (x, -0.32, 0.82),
           (0.055, 0.025, 0.055), ORO, 8)

    # Musleras
    cubo("Muslera_" + lado, (x, 0, 1.00),
         (0.39, 0.42, 0.34), AZUL, 0.085)

    cubo("Placa_muslera_" + lado, (x, -0.225, 1.02),
         (0.29, 0.055, 0.25), AZUL2, 0.045)

    barra("Ribete_muslera_" + lado,
          (x-0.15, -0.27, 1.14),
          (x+0.15, -0.27, 1.14),
          0.018, ORO, 8)

# ------------------------------------------------------------
# CINTURON Y TABARDO
# ------------------------------------------------------------

cubo("Cinturon_principal", (0, -0.015, 1.19),
     (0.91, 0.48, 0.16), CUERO, 0.035)

cubo("Banda_dorada", (0, -0.267, 1.19),
     (0.91, 0.035, 0.045), ORO, 0.012)

cubo("Hebilla", (0, -0.295, 1.19),
     (0.22, 0.065, 0.18), ORO_CLARO, 0.035)

cubo("Centro_hebilla", (0, -0.335, 1.19),
     (0.105, 0.025, 0.09), AZUL, 0.015)

# Tabardo frontal con forma trapezoidal
placa("Tabardo", [
    (-0.29, 1.43),
    (0.29, 1.43),
    (0.34, 0.48),
    (0.0, 0.39),
    (-0.34, 0.48)
], -0.285, 0.035, AZUL_TELA)

# Bordes del tabardo
barra("Borde_tabardo_izq",
      (-0.29, -0.32, 1.42),
      (-0.34, -0.32, 0.49), 0.018, ORO)

barra("Borde_tabardo_der",
      (0.29, -0.32, 1.42),
      (0.34, -0.32, 0.49), 0.018, ORO)

barra("Borde_tabardo_inferior",
      (-0.34, -0.32, 0.49),
      (0.0, -0.32, 0.40), 0.018, ORO)

barra("Borde_tabardo_inferior2",
      (0.0, -0.32, 0.40),
      (0.34, -0.32, 0.49), 0.018, ORO)

# Emblema geométrico del tabardo
esfera("Emblema_tabardo", (0, -0.335, 0.96),
       (0.15, 0.025, 0.20), ORO, 8)

placa("Emblema_punta", [
    (-0.10, 1.02),
    (0.10, 1.02),
    (0.0, 0.82)
], -0.37, 0.018, AZUL)

# ------------------------------------------------------------
# TORSO Y PECHERA
# ------------------------------------------------------------

cubo("Torso_base", (0, 0, 1.52),
     (0.99, 0.56, 0.66), CUERO2, 0.13)

cubo("Coraza_principal", (0, -0.12, 1.57),
     (1.02, 0.43, 0.62), AZUL, 0.13)

# Placas laterales de pecho
for lado, x in (("Izq", -0.34), ("Der", 0.34)):
    placa("Pectoral_" + lado, [
        (x-0.19, 1.80),
        (x+0.19, 1.80),
        (x+0.22, 1.49),
        (x, 1.37),
        (x-0.22, 1.49)
    ], -0.385, 0.055, AZUL2)

    barra("Ribete_pectoral_" + lado,
          (x-0.16, -0.42, 1.77),
          (x+0.16, -0.42, 1.77),
          0.025, ORO)

# Placa central
placa("Pecho_central", [
    (-0.20, 1.83),
    (0.20, 1.83),
    (0.18, 1.49),
    (0.0, 1.40),
    (-0.18, 1.49)
], -0.445, 0.06, AZUL)

# Emblema central
esfera("Medallon_pecho", (0, -0.51, 1.66),
       (0.16, 0.035, 0.17), ORO, 10)

esfera("Gema_pecho", (0, -0.548, 1.66),
       (0.07, 0.018, 0.08), ROJO, 8)

# Placas abdominales
for i in range(3):
    z = 1.38 - i * 0.105
    cubo("Abdominal_" + str(i), (0, -0.405, z),
         (0.65 - i*0.04, 0.08, 0.085), AZUL2, 0.025)

# Costillas laterales
for lado, x in (("Izq", -0.43), ("Der", 0.43)):
    for i in range(3):
        z = 1.43 + i * 0.12
        barra("Costilla_" + lado + str(i),
              (x, -0.35, z),
              (x * 0.82, -0.39, z + 0.04),
              0.025, ORO, 8)

# ------------------------------------------------------------
# CUELLO Y HOMBRERAS GIGANTES
# ------------------------------------------------------------

cilindro("Gorget_cuello", (0, 0, 1.92),
         0.28, 0.18, ORO, 10)

cubo("Protector_cuello", (0, -0.24, 1.91),
     (0.54, 0.14, 0.17), AZUL2, 0.055)

for lado, x in (("Izq", -0.66), ("Der", 0.66)):

    # Base de hombro
    esfera("Hombro_base_" + lado, (x, 0, 1.83),
           (0.39, 0.40, 0.31), AZUL, 12)

    # Gran placa exterior
    placa("Hombrera_gigante_" + lado, [
        (x-0.37, 1.91),
        (x-0.23, 2.12),
        (x+0.23, 2.12),
        (x+0.39, 1.94),
        (x+0.28, 1.70),
        (x, 1.62),
        (x-0.27, 1.70)
    ], -0.31, 0.20, AZUL2)

    # Ribete dorado
    barra("Ribete_hombro_" + lado,
          (x-0.28, -0.43, 1.97),
          (x+0.29, -0.43, 1.97),
          0.035, ORO_CLARO)

    barra("Borde_hombro_exterior_" + lado,
          (x+0.34, -0.35, 1.91),
          (x+0.25, -0.35, 1.70),
          0.035, ORO)

    # Remaches
    for dx in (-0.22, 0, 0.22):
        esfera("Remache_hombro_" + lado,
               (x+dx, -0.44, 1.96),
               (0.045, 0.025, 0.045), ORO_CLARO, 8)

# ------------------------------------------------------------
# RELIEVES DE LEON EN HOMBRERA
# ------------------------------------------------------------

def leon(nombre, x, y, z, escala=1.0):
    # Cabeza central
    esfera(nombre + "_rostro", (x, y, z),
           (0.15*escala, 0.055*escala, 0.16*escala),
           ORO, 10)

    # Melena radial
    for i in range(8):
        ang = math.radians(i * 45)
        px = x + math.cos(ang) * 0.16 * escala
        pz = z + math.sin(ang) * 0.16 * escala
        esfera(nombre + "_melena_" + str(i),
               (px, y+0.008, pz),
               (0.075*escala, 0.045*escala, 0.075*escala),
               ORO_CLARO, 8)

    # Ojos
    for dx in (-0.055, 0.055):
        esfera(nombre + "_ojo",
               (x+dx*escala, y-0.052*escala, z+0.025*escala),
               (0.018*escala, 0.012*escala, 0.018*escala),
               NEGRO, 8)

    # Hocico
    esfera(nombre + "_hocico",
           (x, y-0.06*escala, z-0.065*escala),
           (0.065*escala, 0.035*escala, 0.05*escala),
           ORO_CLARO, 8)

leon("Leon_hombro_izquierdo", -0.66, -0.43, 1.84, 0.95)
leon("Leon_hombro_derecho", 0.66, -0.43, 1.84, 0.95)

# ------------------------------------------------------------
# BRAZOS Y GUANTELETES
# ------------------------------------------------------------

for lado, x in (("Izq", -0.68), ("Der", 0.68)):
    barra("Brazo_superior_" + lado,
          (x, 0, 1.68),
          (x*1.08, 0, 1.34),
          0.15, CUERO2)

    cilindro("Codo_" + lado,
             (x*1.08, 0, 1.32),
             0.16, 0.20, AZUL2, 10)

    barra("Antebrazo_" + lado,
          (x*1.08, -0.01, 1.30),
          (x*1.12, -0.03, 1.00),
          0.14, AZUL, 10)

    cubo("Placa_antebrazo_" + lado,
         (x*1.12, -0.15, 1.17),
         (0.23, 0.12, 0.30), AZUL2, 0.05)

    barra("Ribete_guantelete_" + lado,
          (x*1.12-0.12, -0.22, 1.03),
          (x*1.12+0.12, -0.22, 1.03),
          0.025, ORO, 8)

    esfera("Guante_" + lado,
           (x*1.12, -0.035, 0.91),
           (0.15, 0.13, 0.15), AZUL2, 10)

    for i in range(4):
        dx = (i-1.5)*0.065
        barra("Dedo_" + lado + str(i),
              (x*1.12+dx, -0.13, 0.90),
              (x*1.12+dx, -0.15, 0.81),
              0.025, AZUL, 8)

# ------------------------------------------------------------
# CASCO CERRADO
# ------------------------------------------------------------

# Craneo
esfera("Casco_principal", (0, 0, 2.18),
       (0.32, 0.31, 0.37), AZUL2, 12)

# Placa frontal
placa("Frontal_casco", [
    (-0.25, 2.33),
    (0.25, 2.33),
    (0.22, 2.03),
    (0.0, 1.94),
    (-0.22, 2.03)
], -0.29, 0.12, AZUL)

# Visor oscuro
cubo("Visor_horizontal", (0, -0.365, 2.20),
     (0.34, 0.035, 0.075), NEGRO, 0.018)

# Bordes dorados del visor
barra("Marco_visor_superior",
      (-0.20, -0.39, 2.25),
      (0.20, -0.39, 2.25), 0.025, ORO)

barra("Marco_visor_inferior",
      (-0.20, -0.39, 2.15),
      (0.20, -0.39, 2.15), 0.025, ORO)

# Nariz y proteccion inferior
placa("Protector_nasal", [
    (-0.055, 2.27),
    (0.055, 2.27),
    (0.04, 1.99),
    (0.0, 1.93),
    (-0.04, 1.99)
], -0.405, 0.045, ORO)

# Mandibula
cubo("Mandibula_casco", (0, -0.25, 2.04),
     (0.40, 0.15, 0.17), AZUL2, 0.045)

# Cresta dorada
barra("Cresta_casco",
      (0, 0, 2.40),
      (0, 0, 2.59),
      0.035, ORO, 8)

# Penacho azul
for i in range(7):
    x = (i-3)*0.045
    barra("Pluma_penacho_" + str(i),
          (x*0.4, 0.015, 2.47),
          (x*1.5, 0.12, 2.78-abs(i-3)*0.025),
          0.035, AZUL, 6)

# Protectores laterales
for x in (-0.29, 0.29):
    placa("Protector_lateral_casco", [
        (x-0.04, 2.23),
        (x+0.04, 2.23),
        (x+0.08, 1.93),
        (x-0.04, 1.89)
    ], -0.15, 0.13, ORO)

# ------------------------------------------------------------
# CAPA VOLUMETRICA CON PLIEGUES
# ------------------------------------------------------------

# Malla curva de 13 columnas y 15 filas
cols = 13
rows = 15
vertices = []
caras = []

for j in range(rows):
    t = j / (rows - 1)

    for i in range(cols):
        u = i / (cols - 1)
        x = (u - 0.5) * (0.76 + 0.82*t)
        z = 1.92 - 1.58*t

        # Ondulacion y pliegues
        fold = math.sin(u*math.pi*10 + t*2.0) * 0.055
        y = 0.22 + t*0.24 + fold*t

        # La capa se abre hacia abajo
        x += math.sin(t*2.0) * (u-0.5) * 0.12

        vertices.append((x, y, z))

for j in range(rows-1):
    for i in range(cols-1):
        a = j*cols + i
        b = a+1
        c = a+cols+1
        d = a+cols
        caras.append((a, b, c, d))

capa = malla("Capa_roja_voluminosa", vertices, caras, ROJO)

solid = capa.modifiers.new("Grosor_de_tela", "SOLIDIFY")
solid.thickness = 0.045

sub = capa.modifiers.new("Suavizado_de_tela", "SUBSURF")
sub.levels = 1

# Ribete inferior
for x in (-0.75, 0.75):
    barra("Borde_capa_lateral",
          (x*0.45, 0.42, 1.1),
          (x, 0.48, 0.36),
          0.025, ORO, 8)

# ------------------------------------------------------------
# ESPADA ANCHA
# ------------------------------------------------------------

# Hoja de acero con forma
placa("Hoja_espada", [
    (0.83, 0.82),
    (1.00, 0.82),
    (1.02, 1.95),
    (0.915, 2.16),
    (0.81, 1.95)
], -0.12, 0.075, ACERO)

barra("Filo_espada_izq",
      (0.83, -0.17, 0.87),
      (0.915, -0.17, 2.12),
      0.018, ORO, 6)

barra("Filo_espada_der",
      (1.00, -0.17, 0.87),
      (0.915, -0.17, 2.12),
      0.018, ORO, 6)

barra("Guarda_espada",
      (0.70, -0.14, 0.86),
      (1.13, -0.14, 0.86),
      0.055, ORO, 8)

barra("Empunadura",
      (0.915, -0.14, 0.55),
      (0.915, -0.14, 0.81),
      0.055, CUERO, 8)

esfera("Pomo_espada", (0.915, -0.14, 0.52),
       (0.09, 0.07, 0.09), ORO, 8)

# ------------------------------------------------------------
# ESCUDO GRANDE
# ------------------------------------------------------------

contorno_escudo = [
    (-1.00, 1.88),
    (-0.57, 1.88),
    (-0.50, 1.49),
    (-0.57, 1.05),
    (-0.79, 0.72),
    (-1.00, 0.60),
    (-1.21, 0.72),
    (-1.43, 1.05),
    (-1.50, 1.49),
    (-1.43, 1.88)
]

placa("Escudo_base", contorno_escudo, -0.39, 0.12, ORO)

contorno_interior = [
    (-1.00, 1.80),
    (-0.65, 1.80),
    (-0.60, 1.47),
    (-0.66, 1.09),
    (-0.82, 0.82),
    (-1.00, 0.72),
    (-1.18, 0.82),
    (-1.34, 1.09),
    (-1.40, 1.47),
    (-1.35, 1.80)
]

placa("Escudo_azul", contorno_interior, -0.52, 0.055, AZUL)

# Relieve central
leon("Leon_escudo", -1.0, -0.59, 1.36, 1.15)

# Remaches perimetrales
for x, z in contorno_interior:
    esfera("Remache_escudo", (x, -0.59, z),
           (0.035, 0.025, 0.035), ORO_CLARO, 8)

# Refuerzo central vertical
barra("Refuerzo_escudo",
      (-1.0, -0.61, 0.83),
      (-1.0, -0.61, 1.79),
      0.018, ORO, 6)

# ------------------------------------------------------------
# DETALLES FINALES
# ------------------------------------------------------------

# Correas del torso
for x in (-0.39, 0.39):
    barra("Correa_pecho",
          (x, -0.30, 1.82),
          (x*0.55, -0.43, 1.27),
          0.045, CUERO, 8)

# Hebillas de correas
for x in (-0.30, 0.30):
    esfera("Hebilla_correa", (x, -0.46, 1.55),
           (0.055, 0.025, 0.055), ORO, 8)

# Tachones decorativos de la armadura
for x in (-0.43, 0.43):
    for z in (1.38, 1.51, 1.64):
        esfera("Remache_torso", (x, -0.42, z),
               (0.025, 0.018, 0.025), ORO, 8)

# ------------------------------------------------------------
# ORGANIZACION DE COLECCION
# ------------------------------------------------------------

coleccion = bpy.data.collections.new("CLASSICRPG_CABALLERO_V2")
bpy.context.scene.collection.children.link(coleccion)

for obj in list(bpy.context.scene.objects):
    for col in list(obj.users_collection):
        col.objects.unlink(obj)
    coleccion.objects.link(obj)

# Unidades metricas
bpy.context.scene.unit_settings.system = "METRIC"
bpy.context.scene.unit_settings.scale_length = 1.0

# Seleccion
bpy.ops.object.select_all(action="DESELECT")

for obj in coleccion.objects:
    obj.select_set(True)

bpy.context.view_layer.objects.active = next(iter(coleccion.objects))

# ------------------------------------------------------------
# EXPORTACION
# ------------------------------------------------------------

ruta_blend = os.path.join(CARPETA, NOMBRE + ".blend")
ruta_glb = os.path.join(CARPETA, NOMBRE + ".glb")

# Guardar escena editable
bpy.ops.wm.save_as_mainfile(filepath=ruta_blend)

# Exportar modelo para Godot
if not hasattr(bpy.ops.export_scene, "gltf"):
    raise RuntimeError("Exportador glTF no disponible en Blender.")

bpy.ops.export_scene.gltf(
    filepath=ruta_glb,
    export_format="GLB",
    use_selection=True,
    export_apply=True
)

if not os.path.isfile(ruta_blend):
    raise RuntimeError("No se genero el archivo BLEND.")

if not os.path.isfile(ruta_glb):
    raise RuntimeError("No se genero el archivo GLB.")

print("")
print("==========================================")
print("CLASSICRPG CABALLERO V2 - GENERACION OK")
print("BLEND:", ruta_blend)
print("GLB:", ruta_glb)
print("OBJETOS:", len(coleccion.objects))
print("==========================================")
