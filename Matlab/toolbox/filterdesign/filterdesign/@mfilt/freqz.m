%FREQZ  Frequency response of a multirate filter.
%   [H,W] = FREQZ(Hd,N) returns the N-point complex frequency response
%   vector H and the N-point frequency vector W in radians/sample of the
%   discrete-time multirate filter Hd.  The frequency response is evaluated
%   at N points equally spaced around the upper half of the unit circle. If
%   N isn't specified, it defaults to 8192.
%
%   FREQZ(Hd) with no output argument will launch FVTool in the Magnitude
%   and Phase Response.
%
%   [H,W] = FREQZ(Hd) returns a matrix H if Hd is a vector.  Each column of
%   the matrix corresponds to each filter in the vector.  If a row vector
%   of frequency points is specified, each row of the matrix corresponds to
%   each filter in the vector.
%
%   Note that the frequency response is computed relative to the rate at
%   which the filter is running. If a sampling frequency is specified, it
%   is assumed that the filter is running at that rate.
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
%   For additional parameters, see SIGNAL/FREQZ.
%
%   See also MFILT, SIGNAL/FREQZ, MFILT/COEFFICIENTS, MFILT/GRPDELAY,
%   MFILT/IMPZ, MFILT/INFO, MFILT/PHASEZ, MFILT/STEPZ, MFILT/ZEROPHASE,
%   MFILT/ZPLANE, FVTOOL.

% Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2004/04/12 23:24:52 $

% Help for the filter's FREQZ method.

% [EOF]
