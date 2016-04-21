function [ts,offset,ph,mn]=slidentinit(tso,cbsim,mn)
tso = eval(tso);
ts=tso(1); 
if length(tso) > 1, 
    offset = tso(2), 
else,
    offset = 0; 
end
 
switch cbsim
    case 'Simulation'
        ph = inf;
    otherwise
        ph = eval(cbsim(1:2));
end
if ~isempty(mn)
    try
    assignin('base',mn,{});
catch
    error('The model name must be empty or a string without quotes.')
end
end

% Copyright 2003 The MathWorks, Inc.

%   $Revision: 1.1.4.1 $  $Date: 2004/04/10 23:20:26 $
