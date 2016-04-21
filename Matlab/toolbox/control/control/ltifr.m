function g = ltifr(a,b,s)
%LTIFR	Linear time-invariant frequency response kernel.
%
%	G = LTIFR(A,b,S) calculates the frequency response of the
%	system:
%		 G(s) = (sI - A)\b
%
%	for the complex frequencies in vector S. Column vector b
%	must have as many rows as matrix A. Matrix G is returned
%	with SIZE(A) rows and LENGTH(S) columns.
%	Here is what it implements, in high speed:
%
%		function g = ltifr(a,b,s)
%		ns = length(s); na = length(a);
%		e = eye(na); g = sqrt(-1) * ones(na,ns);
%		for i=1:ns
%		    g(:,i) = (s(i)*e-a)\b;
%		end
%

%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.11 $  $Date: 2002/04/10 06:24:22 $

% RE: Call the built-in function MIMOFR
if ndims(b)>2 | size(b,2)>1,
    error('B must be a vector.')
elseif ndims(a)>2
    error('A must be a matrix');
end
g = mimofr(a,b,[],[],s(:));
g = reshape(g,[length(a) prod(size(s))]);

