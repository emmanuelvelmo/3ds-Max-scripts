-- VARIABLES GLOBALES
texto_espera = "Select one object" -- Texto mostrado cuando no hay una selección válida
ventana_nombre = undefined -- Referencia a la ventana principal

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

-- Genera el nombre automáticamente
fn generar_nombre =
(
    -- Verificar selección
    if selection.count != 1 then
    (
        return texto_espera
    )

    obj_seleccionado = selection[1]

    -- Obtener tamaño del Bounding Box
    limites_objeto = nodeGetBoundingBox obj_seleccionado obj_seleccionado.transform

    punto_minimo = limites_objeto[1]
    punto_maximo = limites_objeto[2]

    tamano_y_pulgadas = punto_maximo.y - punto_minimo.y

    -- Convertir pulgadas a milímetros
    tamano_y_mm = tamano_y_pulgadas * 25.4

    tamano_texto = formattedPrint tamano_y_mm format:"3.2f"

    tamano_texto = limpiar_decimales tamano_texto

    nombre_generado =
        obj_seleccionado.name +
        " (Y " +
        tamano_texto +
        " mm).obj"

    return nombre_generado
)

-- Actualiza la caja de texto
fn actualizar_nombre =
(
    ventana_nombre.txt_nombre.text = generar_nombre()
)

-- Copia el nombre al portapapeles
fn copiar_nombre =
(
    if ventana_nombre.txt_nombre.text != "" and
       ventana_nombre.txt_nombre.text != texto_espera then
    (
        setClipBoardText ventana_nombre.txt_nombre.text
    )
)

-- INTERFAZ

rollout ventana_nombre "Generate Name"
(
    button btn_generar "Generate name" pos:[10,10] width:100 height:24

    button btn_copiar "Copy" pos:[115,10] width:60 height:24

    editText txt_nombre "" pos:[10,42] width:300 height:24 readOnly:true

    -- Generar nombre
    on btn_generar pressed do
    (
        actualizar_nombre()
    )

    -- Copiar nombre
    on btn_copiar pressed do
    (
        copiar_nombre()
    )
)

-- PUNTO DE PARTIDA

try
(
    destroyDialog ventana_nombre
)
catch()

createDialog ventana_nombre 320 75 style:#(#style_titlebar,#style_sysmenu,#style_toolwindow)