function strfcn = functiontostring(fcn)
% FUNCTIONTOSTRING Convert the function to a string for printing.

%   Copyright 1990-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/04/06 01:10:22 $

if ischar(fcn)
    strfcn = fcn;
elseif isa(fcn,'inline')
    strfcn = char(fcn);
elseif isa(fcn,'function_handle')
    strfcn = func2str(fcn);
else
    try
        strfcn = char(fcn);
    catch
        strfcn = '(name not printable)';
    end
end
