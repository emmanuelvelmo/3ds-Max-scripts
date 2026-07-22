-- VARIABLES GLOBALES

centro_capturado = undefined -- Centro calculado en coordenadas locales
ventana_centro_vertices = undefined -- Referencia a la ventana principal

-- FUNCIONES

-- Verifica que exista un único objeto seleccionado
fn verificar_objeto obj_seleccionado =
(
    if obj_seleccionado == undefined then
    (
        messageBox "Select one object."

        return false
    )

    if classOf obj_seleccionado != Editable_Poly then
    (
        messageBox "Selected object must be an Editable Poly."

        return false
    )

    return true
)

-- Obtiene el centro del Bounding Box formado por los vértices seleccionados
fn obtener_centro_vertices obj_seleccionado =
(
    -- Verificar objeto
    if not (verificar_objeto obj_seleccionado) then
    (
        return undefined
    )

    vertices_seleccionados = polyOp.getVertSelection obj_seleccionado

    -- Verificar selección
    if vertices_seleccionados.numberSet == 0 then
    (
        ventana_centro_vertices.lbl_estado.text = "Select vertices"

        return undefined
    )

    vertices_lista = vertices_seleccionados as array

    vertice = polyOp.getVert obj_seleccionado vertices_lista[1]

    minimo_x = vertice.x
    maximo_x = vertice.x

    minimo_y = vertice.y
    maximo_y = vertice.y

    minimo_z = vertice.z
    maximo_z = vertice.z

    -- Buscar extremos
    for indice_vertice in vertices_lista do
    (
        vertice = polyOp.getVert obj_seleccionado indice_vertice

        if vertice.x < minimo_x then minimo_x = vertice.x
        if vertice.x > maximo_x then maximo_x = vertice.x

        if vertice.y < minimo_y then minimo_y = vertice.y
        if vertice.y > maximo_y then maximo_y = vertice.y

        if vertice.z < minimo_z then minimo_z = vertice.z
        if vertice.z > maximo_z then maximo_z = vertice.z
    )

    punto_centro = point3 \
        ((minimo_x + maximo_x) / 2.0) \
        ((minimo_y + maximo_y) / 2.0) \
        ((minimo_z + maximo_z) / 2.0)

    return punto_centro
)

-- Captura el centro y actualiza la interfaz
fn capturar_centro =
(
    if selection.count != 1 then
    (
        ventana_centro_vertices.lbl_estado.text = "Select object"
        ventana_centro_vertices.lbl_coordenadas.text = ""

        return false
    )

    centro = obtener_centro_vertices selection[1]

    if centro == undefined then
    (
        return false
    )

    centro_capturado = centro

    centro_cm = centro * 2.54

    ventana_centro_vertices.lbl_estado.text = "Coordinates generated"

    ventana_centro_vertices.lbl_coordenadas.text =
        "X: " + (formattedPrint centro_cm.x format:"3.3f") +
        "   Y: " + (formattedPrint centro_cm.y format:"3.3f") +
        "   Z: " + (formattedPrint centro_cm.z format:"3.3f")

    return true
)

-- Mueve el objeto seleccionado al centro capturado
fn mover_objeto =
(
    if centro_capturado == undefined then
    (
        messageBox "Capture a center first."

        return false
    )

    if selection.count != 1 then
    (
        ventana_centro_vertices.lbl_estado.text = "Select object"

        return false
    )

    selection[1].pos = centro_capturado

    ventana_centro_vertices.lbl_estado.text = "Coordinates generated"

    return true
)

-- INTERFAZ

rollout ventana_centro_vertices "Vertices center"
(
    button btn_capturar "Capture center" pos:[10,10] width:90 height:24
    button btn_mover "Move object" pos:[105,10] width:90 height:24

    label lbl_estado "" pos:[10,42] width:185 height:16
    label lbl_coordenadas "" pos:[10,62] width:185 height:16

    on btn_capturar pressed do
    (
        capturar_centro()
    )

    on btn_mover pressed do
    (
        undo "Move Object" on
        (
            mover_objeto()
        )
    )

    on ventana_centro_vertices open do
    (
        lbl_estado.text = "Select vertices"
        lbl_coordenadas.text = ""
    )
)

-- PUNTO DE PARTIDA

try
(
    destroyDialog ventana_centro_vertices
)
catch()

createDialog ventana_centro_vertices 205 85 style:#(#style_titlebar,#style_sysmenu,#style_toolwindow)
