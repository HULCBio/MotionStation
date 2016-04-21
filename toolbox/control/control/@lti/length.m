function L = length(sys)
%LENGTH  Overloaded LENGTH for LTI objects.
%
%   LENGTH(SYS) is equivalent to MAX(SIZE(SYS)) for non-empty 
%   LTI arrays and 0 for empty ones.
%
%   See also SIZE.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2002/09/01 23:06:34 $
sizes = size(sys);
if all(sizes)
   L = max(sizes);
else
   L = 0;
end
