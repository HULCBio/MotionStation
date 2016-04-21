%IMPZ  Impulse response of multirate filter.
%   [H,T] = IMPZ(Hm) computes the impulse response of the discrete-time
%   filter Hm, and returns the response in column vector H and a vector of 
%   times (or sample intervals) in T (T = [0 1 2...]'). By default the number of 
%   samples computed is the length of the filter.
%
%   [H,T] = IMPZ(Hm) returns a matrix H if Hm is a vector.  Each column 
%   of the matrix corresponds to each filter in the vector. 
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
%   For additional parameters, see SIGNAL/IMPZ.
%
%   See also SIGNAL/IMPZ, MFILT/FREQZ, MFILT/STEPZ, MFILT/ZPLANE, MFILT/ZEROPHASE.

%   Author(s): P. Costa
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2004/04/12 23:24:54 $

% Help for the filter's pcoded IMPZ method.

% [EOF]
