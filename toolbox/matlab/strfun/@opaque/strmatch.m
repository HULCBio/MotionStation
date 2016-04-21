function i = strmatch(str,strs,flag)
%STRMATCH Find possible matches for strings for Java objects.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/15 03:51:34 $

if (nargin < 3)
  i = strmatch(fromOpaque(str),fromOpaque(strs));
else
  i = strmatch(fromOpaque(str),fromOpaque(strs),fromOpaque(flag));
end

function z = fromOpaque(x)
z=x;

if isjava(z)
  z = char(z);
end

if isa(z,'opaque')
 error(sprintf('Conversion to char from %s is not possible.', class(x)));
end


