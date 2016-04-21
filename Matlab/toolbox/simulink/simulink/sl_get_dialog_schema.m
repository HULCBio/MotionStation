function dlgstruct = sl_get_dialog_schema(h, name)

try
    switch class(h)
        case 'Simulink.Parameter' 
            dlgstruct = dataddg(h, name, 'data');
        case 'Simulink.Signal'
            dlgstruct = dataddg(h, name, 'signal');
        case 'Simulink.BlockDiagram'
            dlgstruct = modelddg(h);
        case 'Simulink.AliasType'
            dlgstruct = aliastypeddg(h, name);
        case 'Simulink.Bus'
            dlgstruct = busddg(h, name);
        case 'Simulink.StructType'
            dlgstruct = structtypeddg(h, name);
        case 'Simulink.BusElement'
            dlgstruct = buselementddg(h, name);
        case 'Simulink.StructElement'
            dlgstruct = structelementddg(h, name);
        case 'Simulink.NumericType'
            dlgstruct = numerictypeddg(h, name); 
        case 'Simulink.Root'
            dlgstruct = rootddg(h);
        case 'Simulink.Line'
            dlgstruct = sigpropddg(h);
        case 'Simulink.Port'
            dlgstruct = sigpropddg(h);
        otherwise            
            if(isa(h, 'Simulink.Parameter'))
                dlgstruct = dataddg(h, name, 'data');
            elseif(isa(h, 'Simulink.Signal'))
                dlgstruct = dataddg(h, name, 'signal');   
            else
                dlgstruct = genericddg(h);
            end
    end
catch
    dlgstruct = errorddg_l(h);
end

function dlgStruct = errorddg_l(h)
txt.Name               = lasterr;
txt.Type               = 'text';
txt.WordWrap           = true;
txt.RowSpan            = [1,1];
spacer.Type            = 'panel';
spacer.RowSpan         = [2,2];
dlgStruct.LayoutGrid   = [2, 1];
dlgStruct.RowStretch   = [0, 1];
dlgStruct.Items        = {txt, spacer};
dlgStruct.DialogTitle  = [h.Type ': ' h.Name];