function resetValues(obj, pNames, pVals)
%resetValues resets the properties of a audioplayer object
%
%    RESETVALUES(OBJ,PNAMES,PVALS) sets the properties of OBJ.  PNAMES and PVALS 
%    are values from the GETSETTABLEVALUES function.
%
%    See Also: AUDIOPLAYER/PRIVATE/GETSETTABLEVALUES
%

%    JCS
%    Copyright 2001-2003 The MathWorks, Inc. 
%    $Revision: 1.1.6.1 $  $Date: 2003/12/04 19:00:43 $

olen = length(obj);
j = obj.internalObj;

for props=1:length(pNames)
    try
        set(j(lcv), pNames{props}, pVal{lcv}{props});
    catch
    end
end

