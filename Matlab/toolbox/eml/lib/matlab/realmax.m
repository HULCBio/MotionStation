function r = realmax(cls)
% Embedded MATLAB Library function.
%
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/realmax.m$
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $Date: 2004/04/14 23:58:33 $
% Decprecated.

if nargin < 1
    cls = 'double';
end

switch cls
    case 'double'
        r = double((2-2^-52)*(2^1023));
    case 'single'
        r = single((2-2^-23)*(2^127));
    otherwise
        eml_assert(0,'error',...
		   'realmax can only handle ''single'' or ''double''');
end
