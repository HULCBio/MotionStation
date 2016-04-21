function bool = isvalidvar(str)
%ISVALIDVAR   Valid variable name test.
% bool = isvalidvar(str)
%  Inputs: 
%     str - string
%  Outputs:
%     bool - 0==> not valid, 1==> valid

%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.8 $

%   Author: T. Krauss

    if length(str)>1
        bool = isletter(str(1)) & ...
                all(isletter(str(2:end))|ismember(str(2:end),'0123456789_'));  
    else
        bool = isletter(str);
    end
