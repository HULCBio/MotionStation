%PHASEDELAY  Phase delay of a multirate filter.
%   [PHI,W] = PHASEDELAY(Hm,N) returns the N-point phase delay response
%   vector PHI and the N-point frequency vector W in radians/sample of the
%   filter. The phase response is evaluated at N points equally spaced
%   around the upper half of the unit circle. If N isn't specified, it
%   defaults to 8192.
%
%   If Hm is a vector of filter objects, Phi becomes a matrix.  Each column
%   of the matrix corresponds to each filter in the vector.  If a row
%   vector of frequency points is specified, each row of the matrix
%   corresponds to each filter in the vector.
%
%   PHASEDELAY(Hm) displays the phase delay response in the Filter
%   Visualization Tool (FVTool).
%
%   Note that the response is computed relative to the rate at which the
%   filter is running. If a sampling frequency is specified, it is assumed
%   that the filter is running at that rate.
%
%   For multistage cascades, an equivalent single-stage multirate filter is
%   formed and the response is computed relative to the rate at which the
%   equivalent filter is running. However, not all multistage cascades are
%   supported. Only cascades in which it is possible to derive an
%   equivalent single-stage filter are allowed for analysis purposes.
%
%   As an example, consider a 2-stage interpolator, where the first stage
%   has an intepolation factor of 2 and the second stage has an
%   interpolation factor of 4. An equivalent filter, with an overall
%   interpolation factor of 8 can be found and is used for analysis
%   purposes. If a sampling frequency is specified, it is interpreted as it
%   being the rate at which this equivalent filter is running.
%
%   For additional parameters, see SIGNAL/PHASEDELAY.
%
%   See also MFILT, SIGNAL/PHASEDELAY, MFILT/FREQZ, SIGNAL/FREQZ,
%   MFILT/GRPDELAY, MFILT/PHASEZ, MFILT/STEPZ, MFILT/ZEROPHASE,
%   MFILT/ZPLANE, FVTOOL.

%   Author: V. Pellissier
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:24:57 $

% Help for the p-coded PHASEZ method of MFILT classes.
