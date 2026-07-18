-- VARIABLES GLOBALES
nombre_base = "" -- Almacena el nombre base del objeto original
cantidad_elementos = 0 -- Cantidad de elementos generados
ventana_separar = undefined -- Referencia a la ventana principal

-- FUNCIONES

-- Verifica si el objeto es válido para el proceso
fn verificar_objeto obj_seleccionado =
(
    -- Verificar que haya un objeto seleccionado
    if obj_seleccionado == undefined then
    (
        messageBox "Select one object."

        return false
    )

    -- Verificar que el objeto sea convertible a Editable Poly
    if not (canConvertTo obj_seleccionado Editable_Poly) then
    (
        messageBox "Selected object cannot be converted to Editable Poly."

        return false
    )

    return true
)

-- Convierte el objeto a Editable Poly si es necesario
fn preparar_objeto obj_seleccionado =
(
    -- Convertir objeto
    if classOf obj_seleccionado != Editable_Poly then
    (
        convertToPoly obj_seleccionado
    )
)

-- Obtiene todos los elementos del objeto
fn obtener_elementos obj_poly =
(
    elementos_encontrados = #() -- Lista de elementos
    caras_procesadas = #{} -- Caras ya procesadas

    numero_caras = polyOp.getNumFaces obj_poly

    -- Recorrer todas las caras
    for indice_cara = 1 to numero_caras do
    (
        -- Procesar únicamente caras pendientes
        if not caras_procesadas[indice_cara] then
        (
            elemento_actual = polyOp.getElementsUsingFace obj_poly indice_cara

            append elementos_encontrados elemento_actual

            caras_procesadas += elemento_actual
        )
    )

    return elementos_encontrados
)

-- Crea un objeto nuevo a partir de un elemento
fn crear_objeto_desde_elemento obj_original elemento_a_mantener indice_elemento =
(
    nuevo_objeto = copy obj_original

    nombre_nuevo = nombre_base + "_Elem_" + (formattedPrint indice_elemento format:"03d")

    nuevo_objeto.name = uniquename nombre_nuevo

    total_caras = polyOp.getNumFaces nuevo_objeto

    caras_a_eliminar = #{1..total_caras}
    caras_a_eliminar -= elemento_a_mantener

    polyOp.deleteFaces nuevo_objeto caras_a_eliminar

    update nuevo_objeto

    return nuevo_objeto
)

-- Ejecuta el proceso de separación
fn separar_elementos obj_seleccionado =
(
    -- Verificar objeto
    if not (verificar_objeto obj_seleccionado) then
    (
        return false
    )

    nombre_base = obj_seleccionado.name

    preparar_objeto obj_seleccionado

    elementos_lista = obtener_elementos obj_seleccionado

    -- Verificar que existan elementos
    if elementos_lista.count == 0 then
    (
        messageBox "No elements found."

        return false
    )

    nuevos_objetos = #()

    -- Crear un objeto por cada elemento
    for indice_elemento = 1 to elementos_lista.count do
    (
        elemento_actual = elementos_lista[indice_elemento]

        nuevo_objeto = crear_objeto_desde_elemento obj_seleccionado elemento_actual indice_elemento

        append nuevos_objetos nuevo_objeto
    )

    hide obj_seleccionado

    select nuevos_objetos

    cantidad_elementos = nuevos_objetos.count

    -- Mostrar cantidad de elementos generados
    if cantidad_elementos == 1 then
    (
        ventana_separar.txt_elementos.text = "1 generated element"
    )
    else
    (
        ventana_separar.txt_elementos.text = (cantidad_elementos as string) + " generated elements"
    )

    return true
)

-- INTERFAZ
rollout ventana_separar "Separate elements"
(
    button btn_separar "Separate Elements" pos:[10,10] width:120 height:24

    editText txt_elementos "" pos:[135,10] width:120 height:24 readOnly:true

    -- Ejecutar separación
    on btn_separar pressed do
    (
        txt_elementos.text = ""

        -- Verificar selección
        if selection.count != 1 then
        (
            messageBox "Select exactly one object."

            return()
        )

        -- Ejecutar proceso
        undo "Separate Elements" on
        (
            separar_elementos selection[1]
        )
    )
)

-- PUNTO DE PARTIDA
try
(
    destroyDialog ventana_separar
)
catch()

createDialog ventana_separar 265 44