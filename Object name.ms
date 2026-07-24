-- VARIABLES GLOBALES
texto_espera = "Select one object" -- Texto mostrado cuando no hay una selección válida
ventana_object_name = undefined -- Referencia a la ventana principal

-- FUNCIONES

-- Elimina ceros innecesarios al final de un número
fn limpiar_decimales texto =
(
    while matchPattern texto pattern:"*0" do
    (
        texto = substring texto 1 (texto.count - 1)
    )

    if matchPattern texto pattern:"*." then
    (
        texto = substring texto 1 (texto.count - 1)
    )

    return texto
)

-- Convierte un tamaño de pulgadas a milímetros y devuelve el texto formateado
fn obtener_tamano_mm valor_pulgadas =
(
    valor_mm = valor_pulgadas * 25.4

    valor_texto = formattedPrint valor_mm format:"3.2f"

    return limpiar_decimales valor_texto
)

-- Genera los tres nombres
fn generar_nombres =
(
    -- Verificar selección
    if selection.count != 1 then
    (
        ventana_object_name.txt_x.text = texto_espera
        ventana_object_name.txt_y.text = texto_espera
        ventana_object_name.txt_z.text = texto_espera

        return false
    )

    obj_seleccionado = selection[1]

    -- Obtener Bounding Box
    limites_objeto = nodeGetBoundingBox obj_seleccionado obj_seleccionado.transform

    punto_minimo = limites_objeto[1]
    punto_maximo = limites_objeto[2]

    tamano_x = punto_maximo.x - punto_minimo.x
    tamano_y = punto_maximo.y - punto_minimo.y
    tamano_z = punto_maximo.z - punto_minimo.z

    texto_x = obtener_tamano_mm tamano_x
    texto_y = obtener_tamano_mm tamano_y
    texto_z = obtener_tamano_mm tamano_z

    nombre_base = obj_seleccionado.name

    ventana_object_name.txt_x.text =
        nombre_base + " (X " + texto_x + " mm).obj"

    ventana_object_name.txt_y.text =
        nombre_base + " (Y " + texto_y + " mm).obj"

    ventana_object_name.txt_z.text =
        nombre_base + " (Z " + texto_z + " mm).obj"

    return true
)

-- Copia el nombre X al portapapeles
fn copiar_nombre_x =
(
    if ventana_object_name.txt_x.text != "" and
       ventana_object_name.txt_x.text != texto_espera then
    (
        setClipBoardText ventana_object_name.txt_x.text
    )
)

-- Copia el nombre Y al portapapeles
fn copiar_nombre_y =
(
    if ventana_object_name.txt_y.text != "" and
       ventana_object_name.txt_y.text != texto_espera then
    (
        setClipBoardText ventana_object_name.txt_y.text
    )
)

-- Copia el nombre Z al portapapeles
fn copiar_nombre_z =
(
    if ventana_object_name.txt_z.text != "" and
       ventana_object_name.txt_z.text != texto_espera then
    (
        setClipBoardText ventana_object_name.txt_z.text
    )
)

-- INTERFAZ

rollout ventana_object_name "Object name"
(
    button btn_generar "Generate names" pos:[10,10] width:260 height:24

    editText txt_x "" pos:[10,44] width:260 height:24 readOnly:true
    button btn_copiar_x "Copy" pos:[275,44] width:50 height:24

    editText txt_y "" pos:[10,74] width:260 height:24 readOnly:true
    button btn_copiar_y "Copy" pos:[275,74] width:50 height:24

    editText txt_z "" pos:[10,104] width:260 height:24 readOnly:true
    button btn_copiar_z "Copy" pos:[275,104] width:50 height:24

    -- Generar nombres
    on btn_generar pressed do
    (
        generar_nombres()
    )

    -- Copiar nombre X
    on btn_copiar_x pressed do
    (
        copiar_nombre_x()
    )

    -- Copiar nombre Y
    on btn_copiar_y pressed do
    (
        copiar_nombre_y()
    )

    -- Copiar nombre Z
    on btn_copiar_z pressed do
    (
        copiar_nombre_z()
    )
)

-- PUNTO DE PARTIDA

try
(
    destroyDialog ventana_object_name
)
catch()

createDialog ventana_object_name 335 140 style:#(#style_titlebar,#style_sysmenu,#style_toolwindow)
