%PHASEZ Phase response of a multirate filter (unwrapped).
%   [Phi,W] = PHASEZ(Hm,N) returns vectors Phi and W containing the phase
%   response of the multirate filter Hm, and the frequencies (in radians)
%   at which it is evaluated. The phase response is evaluated at N points
%   equally spaced around the upper half of the unit circle. If you don't
%   specify N, it defaults to 8192.
%
%   If Hm is a vector of filter objects, Phi becomes a matrix.  Each column
%   of the matrix corresponds to each filter in the vector.  If a row
%   vector of frequency points is specified, each row of the matrix
%   corresponds to each filter in the vector.
%
%   PHASEZ(Hm) display the phase response in the Filter Visualization Tool
%   (FVTool).
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
%   For additional parameters, see SIGNAL/PHASEZ.
%
%   See also MFILT, SIGNAL/PHASEZ, MFILT/FREQZ, SIGNAL/FREQZ,
%   MFILT/GRPDELAY, MFILT/PHASEDELAY, MFILT/STEPZ, MFILT/ZEROPHASE,
%   MFILT/ZPLANE, FVTOOL.

%   Author: V. Pellissier
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2004/04/12 23:24:58 $

% Help for the p-coded PHASEZ method of MFILT classes.
