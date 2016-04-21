function updateplot(hFit)
%UPDATEPLOT Update the plot of this fit

%   $Revision: 1.1.6.3 $  $Date: 2004/01/24 09:32:55 $
%   Copyright 2003-2004 The MathWorks, Inc.

if isequal(hFit.fittype, 'smooth')
   updatesmoothplot(hFit);
else
   updateparamplot(hFit);
end

dfswitchyard('dfupdatelegend', dfgetset('dffig'));
