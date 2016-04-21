%GRPDELAY Group delay of a multirate filter.
%   [Gd,W] = GRPDELAY(Hd,N) returns length N vectors Gd and W containing
%   the group delay of the discrete-time multirate filter Hd, and the
%   frequencies (in radians) at which it is evaluated. Group delay is
%   -d{angle(w)}/dw.  The frequency response is evaluated at N points
%   equally spaced around the upper half of the unit circle.  For an FIR
%   filter where N is a power of two, the computation is done faster using
%   FFTs.  If you don't specify N, it defaults to 8192.
%
%   GRPDELAY(Hd) with no output argument will launch FVTool in Group Delay.
%
%   [Gd,W] = GRPDELAY(Hd) returns a matrix H if Hd is a vector.  Each
%   column of the matrix corresponds to each filter in the vector.  If a
%   row vector of frequency points is specified, each row of the matrix
%   corresponds to each filter in the vector.
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
%   For additional parameters, see SIGNAL/GRPDELAY.
%
%   See also MFILT, SIGNAL/GRPDELAY, MFILT/COEFFICIENTS, MFILT/FREQZ,
%   MFILT/IMPZ, MFILT/INFO, MFILT/PHASEZ, MFILT/STEPZ, MFILT/ZEROPHASE,
%   MFILT/ZPLANE, FVTOOL.

% Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2004/04/12 23:24:53 $

% Help for the filter's GRPDELAY method.

% [EOF]
