function r = eps(cls)
% Embedded MATLAB Library function.
%
% Limitations:
% Can only handle 'single' or 'double'.

% $INCLUDE(DOC) toolbox/matlab/elmat/eps.m$
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $Date: 2004/04/14 23:58:09 $

if nargin < 1
   cls0 = 'double';
else
   cls0 = cls;
end

switch cls0
   case 'double'
        r = double(2^-52);
   case 'single'
       r = single(2^-23);
   otherwise
       eml_assert(0,'error',...
            'EPS can only handle double or single.');
end
