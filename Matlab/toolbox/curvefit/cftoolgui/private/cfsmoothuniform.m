function isuniform = cfsmoothuniform(dataset)
% CFSMOOTHUNIFORM is a helper function for the cftool GUI. Given a DATASET, 
% it returns ISUNIFORM is 1 if the data set is uniform, 0 if it is not. 

% Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.2.2.1 $  $Date: 2004/02/01 21:40:07 $

isuniform = 1;

ds = handle(dataset);

x = ds.x;
sortedx = sort(x);
xdiff = abs(diff(diff(sortedx)));
cutoff = eps*max(abs(sortedx));
if any(xdiff > cutoff)
	isuniform = 0;
end

