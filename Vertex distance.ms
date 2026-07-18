-- VARIABLES GLOBALES
texto_espera = "Select 2 vertices" -- Texto mostrado cuando no hay una selección válida
ventana_distancia = undefined -- Referencia a la ventana principal

-- FUNCIONES

-- Obtiene la distancia entre dos vértices seleccionados
fn obtener_distancia_vertices =
(
    -- Verificar que exista un único objeto seleccionado
    if selection.count != 1 then
    (
        return texto_espera
    )

    obj_seleccionado = selection[1]

    -- Verificar que el objeto sea Editable Poly
    if not (isKindOf obj_seleccionado Editable_Poly) then
    (
        return texto_espera
    )

    vertices_seleccionados = polyOp.getVertSelection obj_seleccionado

    -- Verificar que existan exactamente dos vértices seleccionados
    if vertices_seleccionados.numberSet != 2 then
    (
        return texto_espera
    )

    vertices_lista = vertices_seleccionados as array

    vertice_1 = polyOp.getVert obj_seleccionado vertices_lista[1]
    vertice_2 = polyOp.getVert obj_seleccionado vertices_lista[2]

    distancia_pulgadas = distance vertice_1 vertice_2

    distancia_centimetros = distancia_pulgadas * 2.54

    return formattedPrint distancia_centimetros format:"3.3f"
)

-- Actualiza el contenido de la caja de texto
fn actualizar_distancia =
(
    ventana_distancia.txt_distancia.text = obtener_distancia_vertices()
)

-- Copia el valor actual al portapapeles
fn copiar_distancia =
(
    -- Verificar que exista una distancia válida
    if ventana_distancia.txt_distancia.text != texto_espera then
    (
        setClipBoardText ventana_distancia.txt_distancia.text
    )
)

-- INTERFAZ
rollout ventana_distancia "Vertex Distance"
(
    editText txt_distancia "" pos:[10,10] width:100 height:24 readOnly:true

    button btn_copiar "Copy" pos:[120,10] width:50 height:24

    timer temporizador_actualizacion interval:100 active:true

    -- Actualizar distancia automáticamente
    on temporizador_actualizacion tick do
    (
        actualizar_distancia()
    )

    -- Copiar distancia al portapapeles
    on btn_copiar pressed do
    (
        copiar_distancia()
    )
)

-- PUNTO DE PARTIDA
try
(
    destroyDialog ventana_distancia
)
catch()

createDialog ventana_distancia 180 44 style:#(#style_titlebar,#style_sysmenu,#style_toolwindow)