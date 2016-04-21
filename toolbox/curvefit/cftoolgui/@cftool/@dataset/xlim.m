function minmax = xlim(ds)
%XLIM Return the X data limits for this dataset

% $Revision: 1.4.2.1 $  $Date: 2004/02/01 21:38:31 $
% Copyright 2001-2004 The MathWorks, Inc.


if isempty(ds.x)
   minmax = [];
else
   minmax = [min(ds.x), max(ds.x)];
end
