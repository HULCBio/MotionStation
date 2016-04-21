function [theType, conflict] = ml_type(obj),
%ML_TYPE  Extracts the type of the given input wrt standard MATLAB types and,
%         HG, Simulink, and Stateflow handles.  Handle conflicts between
%         Stateflow and Simulink or Stateflow and HG are detected if requested.
%
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.9.2.1 $  $Date: 2004/04/15 00:58:46 $

    persistent lastDefaultClassId
    
    if isempty(lastDefaultClassId), 
        allClassIds = sf('get', 'default','.id');
        lastDefaultClassId = max(allClassIds);
    end;
    
    theType = 'unknown';
    conflict = logical(0);

    
    if iscell(obj),    theType = 'cell';   return; end;
    if isobject(obj),  theType = 'object'; return; end;
    if ischar(obj),    theType = 'string'; return; end;
    if islogical(obj), theType = 'bool';   return; end;
    if isstruct(obj),  theType = 'struct'; return; end;
    
    %
    % resolve handle (Stateflow handles take precedence)
    %
    if isnumeric(obj),  
        if ~isempty(obj),
            if obj > lastDefaultClassId & obj==fix(obj) & sf('ishandle', obj), % if it's not larger than the class ids, it's not an object id!    
                theType = 'sf_handle'; 
                if (nargout < 2), return; end;
            end;
            if ishandle(obj),
                if isempty(find_system('handle', obj)), 
                    if nargout > 1 & strcmp(theType, 'sf_handle'), conflict = logical(1);
                    else, theType = 'hg_handle'; 
                    end 
                    return;
                else, 
                    if nargout > 1 & strcmp(theType, 'sf_handle'), conflict = logical(1); 
                    else,   theType = 'sl_handle';
                    end;
                    return;
                end;
            end;
        end;
        if theType(1)=='u', theType = 'numeric'; end; % if it's still unknown, set it to numeric.
        return; 
    end;
    

