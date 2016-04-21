function t = isspace(c)
%ISSPACE True for white space characters in Java objects.
 
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/15 03:51:40 $

t = isspace(fromOpaque(c));

function z = fromOpaque(x)
z=x;

if isjava(z)
  z = char(z);
end

if isa(z,'opaque')
 error(sprintf('Conversion to char from %s is not possible.', class(x)));
end

