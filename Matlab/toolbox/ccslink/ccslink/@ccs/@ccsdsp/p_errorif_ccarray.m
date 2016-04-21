function p_errorif_ccarray(cc)
% P_ERRORIF_CCARRAY (Private) checks if CC is an array of objects, and 
% errors out if methods doesn't support that.
 
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2003/11/30 23:07:26 $

if length(cc) ~= 1
    errId = ['MATLAB:FUNCTION:CCSDSPObjectsArray'];
    error(errId,['Method does not support an array of CCSDSP objects.']);
end

    