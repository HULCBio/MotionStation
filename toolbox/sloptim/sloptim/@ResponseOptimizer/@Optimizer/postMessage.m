function postMessage(this,msg,hDisplay)
% Posts message in Optim Progress display.

%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:45:32 $
%   Copyright 1986-2004 The MathWorks, Inc.
if isempty(hDisplay)
   disp(msg)
elseif ishandle(hDisplay)
   hDisplay.append(sprintf('%s\n',msg))
end
