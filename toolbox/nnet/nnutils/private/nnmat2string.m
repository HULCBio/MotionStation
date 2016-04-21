function s = nnmat2string(m)

% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.4 $  $Date: 2002/04/14 21:17:06 $

[rows,cols] = size(m);
s = '[';
for row=1:rows
  if (row ~= 1)
    s = [s sprintf(';\n ')];
  end
  for col=1:cols
    if (col ~= 1)
      s = [s ' '];
    end
    s = [s num2str(m(row,col))];
  end
end
s = [s ']'];
