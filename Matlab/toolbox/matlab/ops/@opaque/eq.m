function z = eq(x1,x2)
%EQ  == for Java objects.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2004/01/24 09:22:22 $

if (isa(x1,'opaque') && ~isjava(x1)) || (isa(x2,'opaque') && ~isjava(x2))
  if isa(x1, 'opaque')
    z = builtin('eq', x1, x2);
  else
    % Make sure that opaque gets to do the equality evaluation.
    z = eq(x2, x1);
  end
  return;
end

if isjava(x1) && isjava(x2)
  z = builtin('isequal', x1, x2);
  return;
end;

try
  if ~isjava(x1)
    if ischar(x1)
      x2 = char(x2);
    else
      if isnumeric(x1)
        x2 = double(x2);
      else
        z = builtin('isequal', x1, x2);
        return;
      end
    end
  else
    if ischar(x2)
      x1 = char(x1);
    else
      if isnumeric(x2)
        x1 = double(x1);
      else
        z = builtin('isequal', x1, x2);
        return;
      end
    end
  end
  z = (x1 == x2);
catch
  z = builtin('isequal', x1, x2);
end


