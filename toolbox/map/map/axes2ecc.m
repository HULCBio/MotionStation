function ecc = axes2ecc(in1,in2)

%AXES2ECC  Compute eccentricity from semimajor and semiminor axes.
%
%   ECC = AXES2ECC(SEMIMAJOR,SEMIMINOR) computes the eccentricity
%   of an ellipse (or ellipsoid of revolution) given the semimajor
%   and semiminor axes.  The input data can be scalar or matrices
%   of equal dimensions.
%
%   ECC = AXES2ECC(VEC) assumes a 2 element vector (VEC) is supplied,
%   where VEC = [SEMIMAJOR SEMIMINOR].
%
%   See also  MAJAXIS, MINAXIS, ECC2FLAT, ECC2N.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $    $Date: 2003/12/13 02:50:09 $

checknargin(1,2,nargin,mfilename);

if nargin == 1
    if numel(in1) ~= 2
        eid = sprintf('%s:%s:numelVecNot2',getcomp,mfilename);
        error(eid,'%s','VEC must be a 2 element vector.');
    else
        checkinput(in1,{'double'},{'real','positive'},mfilename,'VEC',1);
        semimajor = in1(1);
        semiminor = in1(2);
    end
elseif nargin == 2
    semimajor = in1;
    semiminor = in2;
    checkinput(semimajor,{'double'},{'real','positive'},mfilename,'SEMIMAJOR',1);
    checkinput(semiminor,{'double'},{'real','positive'},mfilename,'SEMIMINOR',2);
    if ~isequal(size(semimajor),size(semiminor))
        eid = sprintf('%s:%s:inconsistentSizes',getcomp,mfilename);
        error(eid,'%s','Inconsistent input sizes.');
	end
end

if any(semiminor > semimajor)
    eid = sprintf('%s:%s:invalidAxes',getcomp,mfilename);
    error(eid,'%s','SEMIMINOR axis may not be larger than SEMIMAJOR axis.');
end

%  Compute the eccentricity
ecc = sqrt(semimajor.^2 - semiminor.^2) ./ semimajor;
