-- Crear bounding box ajustado al objeto seleccionado
if selection.count != 1 then
(
    messageBox "Selecciona un objeto."
)
else
(
    -- Obtener objeto seleccionado
    obj = selection[1]

    -- Calcular dimensiones de la caja envolvente del objeto
    bb = nodeGetBoundingBox obj obj.transform
    minP = bb[1]
    maxP = bb[2]

    ancho = maxP.x - minP.x
    largo = maxP.y - minP.y
    alto  = maxP.z - minP.z

    -- Crear caja con las dimensiones calculadas
    caja = box width:ancho length:largo height:alto

    -- Copiar orientación y posición del objeto original
    caja.transform = obj.transform

    -- Recolocar la caja en el pivot del objeto
    caja.transform = obj.transform

    -- Desplazar media altura hacia abajo en coordenadas locales
    in coordsys local
        move caja [0,0,-alto/2]

    -- Asignar nombre único a la caja creada
    caja.name = uniquename (obj.name + "_BBox")
)