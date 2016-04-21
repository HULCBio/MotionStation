% function [vout] = scliv(vin,fac,offset)
%
%   Scale the independent variable elements of a varying matrix by FAC
%   and adds the OFFSET (optional) to each. i.e.
%
%	newiv = fac*oldiv + offset.
%
%   This does nothing for a CONSTANT matrix and returns an error
%   for a SYSTEM matrix.
%
%   See also: *, MMULT, MSCL, SCLIN, SCLOUT, and SEEIV.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [vout] = scliv(vin,fac,offset)
if nargin ~= 2 & nargin ~= 3,
    disp('usage: vout = scliv(vin,fac,offset)')
    return
    end

[type,nr,nc,npts] = minfo(vin);
if type == 'syst',
    error('cannot scale independent variable for a SYSTEM')
    return
    end

if nargin == 2,
    offset = 0;
    end

[i,j] = size(fac);
if i ~= 1 | j ~= 1,
    error('scaling factor must be a scalar')
    return
    end

if type == 'vary',
    iv = getiv(vin);
    iv = offset + fac*iv;
    vout = vin;
    vout(1:npts,nc+1) = iv;
else
    vout = vin;
    end

%--------------------------------------------------------------------------


%
%