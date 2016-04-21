%TF  Transfer function for multirate filter.
%   [NUM,DEN] = TF(Hm) converts multirate filter Hm to numerator and
%   denominator vectors.
%
%   For multistage cascades, an equivalent single-stage multirate filter is
%   formed and the transfer function corresponds to this equivalent filter.
%   However, not all multistage cascades are supported. Only cascades in
%   which it is possible to derive an equivalent single-stage filter are
%   allowed for analysis purposes.
%
%   As an example, consider a 2-stage interpolator, where the first stage
%   has an intepolation factor of 2 and the second stage has an
%   interpolation factor of 4. An equivalent filter, with an overall
%   interpolation factor of 8 can be found and is used to generate the
%   transfer function. 
%
%   See also MFILT/IMPZ, MFILT/ZPK.

%   Author: V. Pellissier, J. Schickler
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2004/04/12 23:25:00 $

% Help for the p-coded TF method of MFILT classes.
