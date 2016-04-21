function isaStruct = cv_isa_struct
%CV_ISA_STRUCT - Generate a structure used to test for objects class

% Copyright 2003 The MathWorks, Inc.

    persistent isas;
    
    if isempty(isas)
    
        allclasses = {  'condition','decision','formatter','mcdcentry','message', ...
                        'modelcov','relation','root','sigranger','slsfobj', ...
                        'table','testdata'};

        isas = struct;
        
        for className = allclasses
            isas = setfield(isas,className{1}, ...
                            eval(['cv(''get'',''default'',''' className{1} '.isa'');']));
        end
    end
     
    isaStruct = isas;
    
    