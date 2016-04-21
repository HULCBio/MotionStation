%ZPK  Multirate filter zero-pole-gain conversion.
%   [Z,P,K] = ZPK(Hm) returns the zeros, poles, and gain corresponding to
%   the multirate filter Hm in vectors Z, P, and scalar K respectively.
%
%   For multistage cascades, an equivalent single-stage multirate filter is
%   formed and the poles and zeros correspond to this equivalent filter.
%   However, not all multistage cascades are supported. Only cascades in
%   which it is possible to derive an equivalent single-stage filter are
%   allowed for analysis purposes.
%
%   As an example, consider a 2-stage interpolator, where the first stage
%   has an intepolation factor of 2 and the second stage has an
%   interpolation factor of 4. An equivalent filter, with an overall
%   interpolation factor of 8 can be found and is used to generate the
%   poles and zeros. 
%
%   See also MFILT/IMPZ, MFILT/TF.

%   Author: V. Pellissier
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2004/04/12 23:25:02 $

% Help for the p-coded ZPK method of MFILT classes.
