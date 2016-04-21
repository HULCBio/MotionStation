%==========================================
function s = nncelltostring(c)

% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.5 $  $Date: 2002/04/14 21:17:09 $


[rows,cols] = size(c);
s = '{';
for row=1:rows
  for col=1:cols
    s = [s mat2string(c{row,col})];
    if (col < cols)
      s = [s sprintf(' ...\n ')];
    end
  end
  if (row < rows)
    s = [s sprintf(';\n ')];
  end
end
s = [s '}'];

%==========================================
function s = mat2string(m)

[rows,cols] = size(m);
s = '[';
for row=1:rows
  if (row ~= 1)
    s = [s sprintf(';\n  ')];
  end
  for col=1:cols
    if (col ~= 1)
      s = [s ' '];
    end
    s = [s num2str(m(row,col))];
  end
end
s = [s ']'];
