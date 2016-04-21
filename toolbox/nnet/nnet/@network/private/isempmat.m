function f=isempmat(m)
%ISEMPMAT True if input is an empty matrix.

%  Mark Beale, 11-31-97
%  Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

if isa(m,'double')
  if any(size(m) == [0 0])
    f = 1;
  else
    f = 0;
  end

% MOVE THIS TO ANOTHER FUNCTION *******
elseif isa(m,'cell')
  [r,c] = size(m);
  f = zeros(r,c);
  for i=1:r
    for j=1:c
      f(i,j) = ~isempmat(m{i,j});
  end
  end
  
else
  f = 0;
end
