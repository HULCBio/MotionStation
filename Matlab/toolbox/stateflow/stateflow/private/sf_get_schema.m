function dlgstruct = getDialogSchema(h, name)

    if isa(h, 'Stateflow.Junction')
        dlgstruct = junctddg(h, name);
    elseif isa(h, 'Stateflow.Event')
        dlgstruct = eventddg(h, name);
    elseif isa(h, 'Stateflow.Target')
        if strcmp(name, 'Target Options') dlgstruct = target_opts_ddg(h, name);
        elseif strcmp(name, 'Coder Options') dlgstruct = coder_opts_ddg(h, name);
        else dlgstruct = targetddg(h, name);
        end
    elseif isa(h, 'Stateflow.Chart') | isa(h, 'Stateflow.EMChart')
        dlgstruct = chartddg(h, name);
    elseif isa(h, 'Stateflow.State') | isa(h, 'Stateflow.Function') | ...
           isa(h, 'Stateflow.Box') | isa(h, 'Stateflow.Note') |...
           isa(h, 'Stateflow.TruthTable') |... 
           isa(h, 'Stateflow.EMFunction')...
        dlgstruct = stateddg(h, name);
    elseif isa(h, 'Stateflow.Transition')
        dlgstruct = transddg(h, name);
    elseif isa(h, 'Stateflow.Data')
        dlgstruct = dataddg(h, name);
    elseif isa(h, 'Stateflow.Machine')
        dlgstruct = machineddg(h, name);
    else
        dlgstruct = [];
    end
      
% Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.2.4 $  $Date: 2004/04/15 00:59:35 $
