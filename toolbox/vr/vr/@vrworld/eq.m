function x = eq(A, B)
%EQ True for equal VRWORLD objects.
%   EQ(A,B) compares two VRWORLD objects, or two vectors of VRWORLD objects
%   (which must be of the same size), or a vector of VRWORLD objects
%   with a single VRWORLD object.
%   Two valid VRWORLD objects are considered equal if they refer to
%   the same world. An invalid VRWORLD object is considered nonequal
%   to any VRWORLD object, including itself.

%   Copyright 1998-2003 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.2.2.3 $ $Date: 2004/04/06 01:11:10 $ $Author: batserve $

% check parameters
if ~isa(A, 'vrworld')
  error('VR:invalidinarg', 'A must be of type VRWORLD.');
end
if ~isa(B, 'vrworld')
  error('VR:invalidinarg', 'B must be of type VRWORLD.');
end

% Scalar expansion
if any(size(A) ~= size(B))
  if numel(A)==1
    A = A(ones(size(B)));
  elseif numel(B)==1
    B = B(ones(size(A)));
  else
    error('VR:dimnotagree', 'Matrix dimensions must agree.');
  end
end
    
% do it
x = false(size(A));
for k = 1:numel(A)
  x(k) = isvalid(A(k)) && isvalid(B(k)) && (A(k).id == B(k).id);
end
