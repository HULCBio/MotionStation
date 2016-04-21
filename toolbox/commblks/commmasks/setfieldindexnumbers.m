function setfieldindexnumbers(block)
%SETFIELDINDEXNUMBERS Set index numbers in the callers workspace.
%
%   The field numbers will have the same name (and case) as the mask variable 
%   names, BUT they will have their first initial capitalized and preceded 
%   by 'idx'. For example a Dialog variable 'fooBar' creates an index                    
%   called 'idxFooBar'                                                         

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/03/08 21:01:39 $

    evalStr1 = '';
   
    MN = get_param(block,'MaskNames');

    for n=1:length(MN)
        varName  = [upper(MN{n}(1)) MN{n}(2:end)];
        evalStr1 = [evalStr1 sprintf('idx%s = %d;', varName, n)];
    end;
    
    evalin('caller',evalStr1);

return;
