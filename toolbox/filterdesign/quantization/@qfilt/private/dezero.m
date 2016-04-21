function x1 = dezero(x)
%DEZERO Remove trailing zeros.
%   DEZERO(X) removes trailing zeros from numeric vector X.  Note that if X
%   is all zeros, then [] is returned.
%  
%
%   Modified from DEBLANK

%   Thomas A. Bryan
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/04/12 23:25:54 $

if ~isempty(x) & ~isnumeric(x) & ~privisvector(x)
    warning('Input must be a numeric vector.')
end

if isempty(x)
  x1 = x([]);
elseif length(x)==1
  % If it's a scalar, don't do anything.  The scalar could be zero and we
  % don't want to return an empty.
  x1 = x;
else
  % remove trailing zeros
  r = find(x ~= 0);
  if isempty(r)
    x1 = x([]);
  else
    x1 = x(1:max(r));
  end
end

