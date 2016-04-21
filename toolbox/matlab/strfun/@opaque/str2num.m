function x = str2num(s)
%STR2NUM Convert Java string object to numeric array.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $ $Date: 2002/04/15 03:51:43 $

x = str2num(fromOpaque(s));

function z = fromOpaque(x)
z=x;

if isjava(z)
  z = char(z);
end

if isa(z,'opaque')
 error(sprintf('Conversion to char from %s is not possible.', class(x)));
end
