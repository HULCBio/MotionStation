function r = realmin(cls)
% Embedded MATLAB Library function.
%
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/realmin.m$
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $Date: 2004/04/14 23:58:34 $
% Deprecated.

if nargin < 1
    cls = 'double';
end

switch cls
    case 'double'
        r = double(2^-1022);
    case 'single'
        r = single(2^-126);
    otherwise
        eml_assert(0,'error',...
		   'realmin can only handle ''single'' or ''double''');
end
