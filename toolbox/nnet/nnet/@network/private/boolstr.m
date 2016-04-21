function s=boolstr(b)
%BOOLSTR Create string summary of a boolean matrix.

%  Mark Beale, 11-31-97
%  Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

if prod(size(b)) > 12
  s = sprintf('[%gx%g boolean]',size(b,1),size(b,2));
else
  s = '[';
  for i=1:size(b,1)
    if (i > 1)
    s = [s '; '];
  end
    for j=1:size(b,2)
    if (j > 1)
        s = [s sprintf(' %g',b(i,j))];
      else
        s = [s sprintf('%g',b(i,j))];
    end
    end
  end
  s = [s ']'];
end
  
