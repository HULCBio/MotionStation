function s = strcmp(s1,s2)
%STRCMP Compare strings for Java objects.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $ $Date: 2002/04/15 03:51:19 $

s = strcmp(fromOpaque(s1),fromOpaque(s2));

function z = fromOpaque(x)
z=x;

if isjava(z)
  z = char(z);
end

if isa(z,'opaque')
 error(sprintf('Conversion to char from %s is not possible.', class(x)));
end

