function n = ecc2n(parm)

%ECC2N  Computes the parameter n of an ellipse given an eccentricity
%
%  n = ECC2N(mat) computes the parameter n of an ellipse (or
%  ellipsoid of revolution) given the eccentricity.  n is defined
%  as (a-b)/(a+b), where a = semimajor axis, b = semiminor axis.
%  If the input is a column vector, then each column element is assumed
%  to be an eccentricity.  If the input has two columns, then the
%  second column is assumed to be the eccentricity.  This allows
%  geoid vectors from ALMANAC to be used as inputs.  If the
%  input is a n x m matrix, where m ~= 2, then each element is assumed
%  to be an eccentricity and the corresponding n is calculated.
%
%  See also:  N2ECC, ECC2FLAT, MAJAXIS, MINAXIS

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.10.4.1 $    $Date: 2003/08/01 18:16:04 $


if nargin == 0
    error('Incorrect number of arguments')
end

%  Dimension tests

if min(size(parm)) == 1 & ndims(parm) <= 2

	col = min(size(parm,2), 2);   % Select first or second column
	eccent = parm(:,col);         % First col if single vector input
	                              % Second col if two column inputs (eg. geoid vecs)
else
    eccent = parm;                %  General matrix input
end

%  Ensure real inputs

if ~isreal(eccent)
   warning('Imaginary parts of complex argument ignored')
   eccent = real(eccent);
end

%  Compute n

n = (1 - sqrt(1 - eccent.^2)) ./ (1 + sqrt(1 - eccent.^2));
