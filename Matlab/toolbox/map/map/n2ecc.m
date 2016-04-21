function eccent = n2ecc(parm)

%N2ECC  Computes the eccentricity of an ellipse given the parameter n
%
%  e = N2ECC(mat) computes the eccentricity of an ellipse (or
%  ellipsoid of revolution) given the parameter n.  n is defined
%  as (a-b)/(a+b), where a = semimajor axis, b = semiminor axis.
%  If the input is a column vector, then each column element is assumed to be
%  the parameter n.  If the input has two columns, then the second column
%  is assumed to be the parameter n.  If the input is a n x m matrix,
%  where m ~= 2, then each element is assumed to be the parameter n
%  and the corresponding eccentricity is calculated.
%
%  See also:  ECC2N, N2ECC, AXES2ECC

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.10.4.1 $    $Date: 2003/08/01 18:17:16 $

if nargin == 0
    error('Incorrect number of arguments')
end

%  Dimension tests

if min(size(parm)) == 1 & ndims(parm) <= 2

	col = min(size(parm,2), 2);   % Select first or second column
	n   = parm(:,col);            % First col if single vector input
	                              % Second col if two column inputs (eg. geoid vecs)
else
    n = parm;        %  General matrix input
end

%  Ensure real inputs

if ~isreal(n)
   warning('Imaginary parts of complex argument ignored')
   n = real(n);
end

%  Compute the eccentricity

eccent = sqrt( 4*n ./ (1+n).^2 );
