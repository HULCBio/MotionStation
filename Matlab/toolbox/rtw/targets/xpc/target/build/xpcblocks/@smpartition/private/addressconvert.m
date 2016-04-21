function addnum = addressconvert(S,addparam)
% ADDRESSCONVERT - converts an address parameter into it's 
%  equivalent numeric value. 
%   
% See also SMPARTITION

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2004/01/22 18:34:55 $

if isnumeric(addparam),
    addnum = round(addparam);
elseif ischar(addparam),
    if length(addparam) > 2 &&...
          addparam(1) == '0' &&...
          addparam(2) == 'x',
       addnum = hex2dec(addparam(3:end));
    else
       addnum = hex2dec(addparam);
    end
else
    error('Address must be a signed integer or hexidecimal string');
end

