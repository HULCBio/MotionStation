function bool = isa(var,type)
% Embedded MATLAB Library function.
%
% Limitations:
% 1) The only valid class types are: numeric, single, double and char.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/isa.m $
%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/14 23:58:16 $

eml_assert(nargin == 2, 'error', 'Not enough input arguments.');
eml_assert(strcmp(class(type),'char'),'''type'' must be a string');

if strcmp(type,'numeric')
    bool = strcmp(class(var),'single') || strcmp(class(var),'double');
else
    bool = strcmp(class(var),type);
end
