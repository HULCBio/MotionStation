function y = all(x)
% Embedded MATLAB Library function.
%
% Limitations:
%   (1) Doesn't work with complex inputs

% $INCLUDE(DOC) toolbox/lib/eml/matlab/all.m $
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $Date: 2004/04/01 16:07:04 $

eml_assert(nargin > 0, 'error', 'Not enough input arguments.');
eml_assert(isreal(x),  'error', 'Complex inputs are not supported.' );

if isempty(x) 
  y = true;
else
  if(size(x,1) == 1 || size(x,2) == 1)
    y = eml_all(x);
  else
    y = logical(zeros(1,size(x,2)));
    
    for i = 1 : size(x,2)
      y(i) = eml_all(x(:,i));
    end
  end
end

