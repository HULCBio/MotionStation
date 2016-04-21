function y=active(x)
%ACTIVE Returns number of structures in cell array.

%  Mark Beale, 11-31-97
%  Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

y = 0;
for i=1:size(x,1)
  for j=1:size(x,2)
    if isa(x{i,j},'struct')
      y=y+1;
  end
  end
end
