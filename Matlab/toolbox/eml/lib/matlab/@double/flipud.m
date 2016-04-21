function y = flipud(x)
% Embedded MATLAB Library function.
%   
% Limitations:
% 1) Can only handle matrix dimensions of 1 or 2.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/@double/flipud.m $
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/14 23:57:55 $

eml_assert(nargin > 0,'error','Not enough input arguments.');
eml_assert(length(size(x)) == 2, 'error', 'Only 2D matrices are supported.');

m = size(x,1);
y = x(m:-1:1,:);