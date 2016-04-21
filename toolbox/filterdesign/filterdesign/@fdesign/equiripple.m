%EQUIRIPPLE   Design an equiripple filter.
%   H = EQUIRIPPLE(D) designs an equiripple filter using the specifications
%   in D.  This filter design will minimize the maximum ripple.
%   
%   H will be either a single-rate digital filter, DFILT, or a multirate
%   digital filter, MFILT, depending on the specification type D.
%
%   H = EQUIRIPPLE(D, 'DensityFactor', DF) designs an equiripple filter
%   using a density factor of DF.
%
%   % Example #1, design a single-rate halfband filter:
%   h = fdesign.halfband;
%   Hd = equiripple(h);
%
%   % Example #2, design a multirate halfband interpolator filter:
%   h = fdesign.interp(2);
%   Hm = equiripple(h);
%
%   See also FDESIGN/FIRLS, FDESIGN/KAISERWIN.

%   Author(s): J. Schickler
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/12 23:17:21 $

% [EOF]
