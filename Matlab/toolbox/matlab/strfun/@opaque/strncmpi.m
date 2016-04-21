function s = strncmpi(s1,s2,n)
%STRNCMPI Compare first N characters of strings ignoring case for Java objects.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $ $Date: 2002/04/15 03:51:28 $

s = strncmpi(fromOpaque(s1),fromOpaque(s2),fromOpaque(n));

function z = fromOpaque(x)
z=x;

if isjava(z)
  z = char(z);
end

if isa(z,'opaque')
 error(sprintf('Conversion to char from %s is not possible.', class(x)));
end


