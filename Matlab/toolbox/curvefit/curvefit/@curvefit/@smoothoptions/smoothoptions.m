function h = smoothoptions
% SMOOTHOPTIONS Constructor for smoothoptions object.

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.8.2.1 $  $Date: 2004/02/01 21:41:46 $

h = curvefit.smoothoptions;

h.method = 'SmoothingSpline';
h.SmoothingParam = [];  % default
