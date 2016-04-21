function y = any(x)
% Embedded MATLAB Library function.
%
% Limitations:
%   (1) Doesn't work with complex inputs

% $INCLUDE(DOC) toolbox/eml/lib/matlab/any.m $
%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/04/14 23:57:59 $

eml_assert(nargin > 0, 'error', 'Not enough input arguments.' );
eml_assert(isreal(x),  'error', 'Complex inputs are not supported.' );

if isempty(x)
  y = false;
else 
  if(size(x,1) == 1 || size(x,2) == 1)
    y = eml_any(x);
  else
    y = logical(zeros(1,size(x,2)));
    
    for i = 1 : size(x,2)
      y(i) = eml_any(x(:,i));
    end
  end
end
