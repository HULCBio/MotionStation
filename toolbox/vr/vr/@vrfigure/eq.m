function x = eq(A, B)
%EQ True for equal VRFIGURE handles.
%   EQ(A,B) compares two VRFIGURE handles, or two vectors of VRFIGURE handles
%   (which must be of the same size), or a vector of VRFIGURE handles
%   with a single VRFIGURE handle.
%   Two VRFIGURE handles are considered equal if they refer to
%   the same figure. An invalid VRFIGURE handle is considered nonequal
%   to any VRFIGURE handle, including itself.

%   Copyright 1998-2003 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.2.2.1 $ $Date: 2003/04/12 23:20:55 $ $Author: batserve $

% check parameters
if ~isa(A, 'vrfigure') || ~isa(B, 'vrfigure')
  error('VR:invalidinarg', 'Both arguments must be of type VRFIGURE.');
end

% Scalar expansion
if any(size(A) ~= size(B))
  if all(size(A)==1)
    A = A(ones(size(B)));
  elseif all(size(B)==1)
    B = B(ones(size(A)));
  else
    error('VR:dimnotagree', 'Matrix dimensions must agree.');
  end
end
    
% do it
x = false(size(A));
for k = 1:numel(A)
  x(k) = isvalid(A(k)) && isvalid(B(k)) && (A(k).handle==B(k).handle);
end
