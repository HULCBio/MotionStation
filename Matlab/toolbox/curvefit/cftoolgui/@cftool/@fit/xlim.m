function minmax=xlim(fit)
%XLIM Return the X data limits for this fit

%   $Revision: 1.5.2.1 $  $Date: 2004/02/01 21:38:43 $
%   Copyright 2001-2004 The MathWorks, Inc.


ds = fit.dshandle;
if ~isempty(ds) & ~isempty(ds.x)
   x = getxdata(ds,fit.outlier);
   minmax = [min(x) max(x)];
else
   minmax = [];
end

