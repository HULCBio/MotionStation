function d = getdescription(fit)
%GETDESCRIPTION Get description suitable for legend or fit tips

%   $Revision: 1.1.6.3 $  $Date: 2004/01/24 09:32:45 $
%   Copyright 2003-2004 The MathWorks, Inc.

if isequal(fit.fittype, 'smooth')
   d = sprintf('smooth(%s,%g)',fit.kernel,fit.bandwidth);
else
   paramstr = sprintf('%g, ',fit.params);
   paramstr(end-1:end) = [];
   d = sprintf('%s(%s)',fit.distspec.name,paramstr);
end

