function h = llsqoptions
%LLSQOPTIONS Constructor for llsqoptions object.

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.5.2.1 $  $Date: 2004/02/01 21:41:13 $

h = curvefit.llsqoptions;
h.method = 'LinearLeastSquares';
h.Robust = 'off';
h.Lower = [];
h.Upper = [];

