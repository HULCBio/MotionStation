function minmax=xlim(fit)
%XLIM Return the X data limits for this fit

%   $Revision: 1.1.6.3 $  $Date: 2004/01/24 09:32:57 $
%   Copyright 2003-2004 The MathWorks, Inc.


ds = fit.dshandle;
if ~isempty(ds) & ~isempty(ds.x)
   x = getincludeddata(ds,fit.exclusionrule);
   minmax = [min(x) max(x)];
else
   minmax = [];
end

