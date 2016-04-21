function bool = isfloat(x)
% Embedded MATLAB Library function.
%
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/isfloat.m $
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2004/04/14 23:58:19 $

bool = isa(x,'double') || isa(x,'single');
