function bool = isnumeric(array)
% Embedded MATLAB Library function.
%
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/isnumeric.m $
%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/14 23:58:22 $

eml_assert(nargin > 0, 'error', 'Not enough input arguments.');

bool = isa(array,'numeric');
