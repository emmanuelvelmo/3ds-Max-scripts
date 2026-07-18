-- VARIABLES GLOBALES
cantidad_cajas = 0 -- Cantidad de cajas generadas
ventana_bounding_box = undefined -- Referencia a la ventana principal

-- FUNCIONES

-- Verifica que exista un objeto válido seleccionado
fn verificar_objeto obj_seleccionado =
(
    -- Verificar que exista un objeto seleccionado
    if obj_seleccionado == undefined then
    (
        messageBox "Select one object."

        return false
    )

    return true
)

-- Crea una caja ajustada a los límites del objeto
fn crear_bounding_box obj_seleccionado =
(
    -- Verificar objeto
    if not (verificar_objeto obj_seleccionado) then
    (
        return false
    )

    -- Obtener límites del objeto
    limites_objeto = nodeGetBoundingBox obj_seleccionado obj_seleccionado.transform

    punto_minimo = limites_objeto[1]
    punto_maximo = limites_objeto[2]

    ancho_caja = punto_maximo.x - punto_minimo.x
    largo_caja = punto_maximo.y - punto_minimo.y
    alto_caja = punto_maximo.z - punto_minimo.z

    -- Crear caja
    caja_generada = box width:ancho_caja length:largo_caja height:alto_caja

    -- Copiar transformación del objeto
    caja_generada.transform = obj_seleccionado.transform

    -- Desplazar media altura en coordenadas locales
    in coordsys local
    (
        move caja_generada [0,0,-alto_caja / 2]
    )

    -- Asignar nombre único
    caja_generada.name = uniquename (obj_seleccionado.name + "_BBox")

    cantidad_cajas = 1

    ventana_bounding_box.txt_resultado.text = "Box generated"

    return true
)

-- INTERFAZ
rollout ventana_bounding_box "Bounding Box"
(
    button btn_generar "Generate box" pos:[10,10] width:80 height:24

    editText txt_resultado "" pos:[100,10] width:100 height:24 readOnly:true

    -- Generar caja
    on btn_generar pressed do
    (
        txt_resultado.text = ""

        -- Verificar selección
        if selection.count != 1 then
        (
            messageBox "Select exactly one object."

            return()
        )

        -- Ejecutar proceso
        undo "Generate Bounding Box" on
        (
            crear_bounding_box selection[1]
        )
    )
)

-- PUNTO DE PARTIDA
try
(
    destroyDialog ventana_bounding_box
)
catch()

createDialog ventana_bounding_box 210 44
