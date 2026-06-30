-- Script para separar todos los elementos de un objeto en objetos independientes
-- Versión: 1.0
-- Funcionamiento: Crea copias del objeto original y elimina las caras que no
-- corresponden a cada elemento, generando objetos separados

-- VARIABLES GLOBALES
nombre_base = "" -- Almacena el nombre base del objeto original

-- FUNCIONES

-- Función para verificar si el objeto es válido para el proceso
fn verificar_objeto obj_seleccionado =
(
    -- Verificar que haya un objeto seleccionado
    if obj_seleccionado == undefined then
    (
        messageBox "Selecciona un objeto para procesar."
        
        return false
    )
    
    -- Verificar que el objeto sea convertible a Editable Poly
    if not (canConvertTo obj_seleccionado Editable_Poly) then
    (
        messageBox "El objeto seleccionado no puede convertirse a Editable Poly."
        
        return false
    )
    
    return true
)

-- Función para preparar el objeto (convertir a editable poly)
fn preparar_objeto obj_seleccionado =
(
    -- Si no es editable poly, convertirlo
    if classOf obj_seleccionado != Editable_Poly then
    (
        convertToPoly obj_seleccionado
    )
)

-- Función para obtener todos los elementos del objeto
fn obtener_elementos obj_poly =
(
    -- Array para almacenar los conjuntos de caras de cada elemento
    elementos_encontrados = #()
    
    -- Conjunto de caras ya procesadas
    caras_procesadas = #{}
    
    -- Obtener número total de caras
    numero_caras = polyOp.getNumFaces obj_poly
    
    -- Recorrer cada cara para identificar elementos únicos
    for indice_cara = 1 to numero_caras do
    (
        -- Verificar si esta cara ya fue procesada
        if not caras_procesadas[indice_cara] then
        (
            -- Obtener todas las caras del elemento actual
            elemento_actual = polyOp.getElementsUsingFace obj_poly indice_cara
            
            -- Agregar elemento a la lista
            append elementos_encontrados elemento_actual
            
            -- Marcar todas las caras del elemento como procesadas
            caras_procesadas += elemento_actual
        )
    )
    
    return elementos_encontrados
)

-- Función para crear un objeto a partir de un elemento específico
fn crear_objeto_desde_elemento obj_original elemento_a_mantener indice_elemento =
(
    -- Crear una copia del objeto original
    nuevo_objeto = copy obj_original
    
    -- Asignar nombre único
    nombre_nuevo = nombre_base + "_Elem_" + (formattedPrint indice_elemento format:"03d")
    
    nuevo_objeto.name = uniquename nombre_nuevo
    
    -- Obtener todas las caras del nuevo objeto
    total_caras = polyOp.getNumFaces nuevo_objeto
    
    -- Crear conjunto de caras a eliminar (todas excepto las del elemento)
    caras_a_eliminar = #{1..total_caras}
    caras_a_eliminar -= elemento_a_mantener
    
    -- Eliminar caras que no pertenecen al elemento
    polyOp.deleteFaces nuevo_objeto caras_a_eliminar
    
    -- Actualizar el objeto
    update nuevo_objeto
    
    return nuevo_objeto
)

-- Función principal que orquesta el proceso de separación
fn separar_elementos obj_seleccionado =
(
    -- Verificar validez del objeto
    if not (verificar_objeto obj_seleccionado) then
    (
        return false
    )
    
    -- Guardar nombre base del objeto original
    nombre_base = obj_seleccionado.name
    
    -- Preparar objeto (convertir a editable poly)
    preparar_objeto obj_seleccionado
    
    -- Obtener lista de elementos
    elementos_lista = obtener_elementos obj_seleccionado
    
    -- Verificar que haya elementos
    if elementos_lista.count == 0 then
    (
        messageBox "No se encontraron elementos en el objeto."
        
        return false
    )
    
    -- Mostrar cantidad de elementos encontrados
    format "Elementos encontrados: %\n" elementos_lista.count
    
    -- Array para almacenar los nuevos objetos creados
    nuevos_objetos = #()
    
    -- Bucle para procesar cada elemento
    for i = 1 to elementos_lista.count do
    (
        -- Obtener el elemento actual
        elemento_actual = elementos_lista[i]
        
        -- Crear nuevo objeto a partir del elemento
        nuevo_obj = crear_objeto_desde_elemento obj_seleccionado elemento_actual i
        
        -- Agregar al array de nuevos objetos
        append nuevos_objetos nuevo_obj
    )
    
    -- Ocultar el objeto original
    hide obj_seleccionado
    
    -- Seleccionar todos los nuevos objetos creados
    select nuevos_objetos
    
    -- Mostrar mensaje de éxito
    messageBox ("Se crearon " + (nuevos_objetos.count as string) + " objetos a partir de los elementos.")
    
    return true
)

-- PUNTO DE PARTIDA

-- Envolver en un bloque de deshacer
undo "Separar Elementos" on
(
    -- Verificar que haya al menos un objeto seleccionado
    if selection.count != 1 then
    (
        messageBox "Selecciona EXACTAMENTE un objeto para procesar."
    )
    else
    (
        -- Obtener el objeto seleccionado
        obj_seleccionado = selection[1]
        
        -- Ejecutar el proceso principal
        separar_elementos obj_seleccionado
    )
)