function x = eq(A, B)
%EQ True for equal VRNODE objects.
%   EQ(A,B) compares two VRNODE objects, or two vectors of VRNODE objects
%   (which must be of the same size), or a vector of VRNODE objects
%   with a single VRNODE object.
%   Two valid VRNODE objects are considered equal if they refer to
%   the same node. An invalid VRNODE object is considered nonequal
%   to any VRNODE object, including itself.

%   Copyright 1998-2003 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.3.2.1 $ $Date: 2003/10/17 18:01:27 $ $Author: batserve $

% check parameters
if ~isa(A, 'vrnode')
  error('A must be of type VRNODE.');
end
if ~isa(B, 'vrnode')
  error('B must be of type VRNODE.');
end

% Scalar expansion
if any(size(A) ~= size(B))
  if all(size(A)==1)
    A = A(ones(size(B)));
  elseif all(size(B)==1)
    B = B(ones(size(A)));
  else
    error('Matrix dimensions must agree.');
  end
end
    
% do it
x = false(size(A));
for k = 1:numel(A)
  x(k) = isvalid(A(k)) && isvalid(B(k)) && (A(k).World==B(k).World) ...
         && strcmp(A(k).Name, B(k).Name);
end
