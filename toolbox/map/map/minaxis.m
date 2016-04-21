function semiminor = minaxis(in1,in2)

%MINAXIS  Computes semiminor axis given a semimajor axis and an eccentricity
%
%  b = MINAXIS(semimajor,e) computes the semiminor axis of an ellipse
%  (or ellipsoid of revolution) given the semimajor axis and eccentricity.
%  The input data can be scalar or matrices of equal dimensions.
%
%  b = MINAXIS(vec) assumes a 2 element vector (vec) is supplied,
%  where vec = [semimajor, e].
%
%  See also:  AXES2ECC, FLAT2ECC, MAJAXIS, N2ECC

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:17:14 $

if nargin == 0
    error('Incorrect number of arguments')

elseif nargin == 1
    if ~isequal(sort(size(in1)),[1 2])
         error('Input must be a 2 element vector')
    else
         semimajor = in1(1);    eccent    = in1(2);
    end

elseif nargin == 2
    if ~isequal(size(in1),size(in2))
         error('Inconsistent input dimensions')
	else
          semimajor = in1;    eccent  = in2;
	end
end

%  Ensure real inputs

if any([~isreal(eccent) ~isreal(semimajor)])
   warning('Imaginary parts of complex arguments ignored')
   eccent = real(eccent);   semimajor = real(semimajor);
end

%  Compute the semiminor axis

semiminor = semimajor .* sqrt(1 - eccent.^2);

