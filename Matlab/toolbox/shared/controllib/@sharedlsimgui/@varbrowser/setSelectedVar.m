function setSelectedVar(h,varname)
% SETSELECTEDVARINFO  Selects the variable named varname

% Author(s): 
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:25:14 $

for k=1:length(h.variables)
    if strcmp(varname,getfield(h.variables(k),'name'))
        awtinvoke(h.javahandle,'setSelectedIndex',k-1);
    end
end
