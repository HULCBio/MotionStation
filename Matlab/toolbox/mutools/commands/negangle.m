% function y = negangle(x)
%
%   Calculate the angle of X, in the range 0 to -2 pi radians.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function y = negangle(x)
if nargin ~= 1,
	disp('usage: y = negangle(x)')
	return
	end

y = angle(x);
ind = find(y > 0);
y(ind) = y(ind) - 2*pi;
%
%