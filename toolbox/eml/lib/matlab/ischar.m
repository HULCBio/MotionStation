function bool = ischar(var)
% Embedded MATLAB Library function.
%
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/ischar.m $
%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/14 23:58:17 $

eml_assert(nargin == 1, 'error', 'Incorrect number of inputs.');
bool = isa(var,'char');
