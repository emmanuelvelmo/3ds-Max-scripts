rollout DistanciaVertices "Distancia Vértices" width:250 height:65
(
    editText txtDist "" pos:[10,10] width:160 height:22 readOnly:true
    button btnCopy "Copiar" pos:[175,10] width:65 height:22

    timer t interval:100 active:true

    fn actualizar =
    (
        local texto = "Seleccione 2 vértices"

        if selection.count == 1 then
        (
            local obj = selection[1]

            if isKindOf obj Editable_Poly then
            (
                local sel = polyOp.getVertSelection obj

                if sel.numberSet == 2 then
                (
                    local ids = sel as array

                    local p1 = polyOp.getVert obj ids[1]
                    local p2 = polyOp.getVert obj ids[2]

                    local d = distance p1 p2
                    local cm = d * 2.54

                    texto = formattedPrint cm format:"3.3f"
                )
            )
        )

        txtDist.text = texto
    )

    on t tick do actualizar()

    on btnCopy pressed do
    (
        if txtDist.text != "Seleccione 2 vértices" then
        (
            setClipBoardText txtDist.text
        )
    )
)

createDialog DistanciaVertices style:#(#style_titlebar,#style_sysmenu,#style_toolwindow)