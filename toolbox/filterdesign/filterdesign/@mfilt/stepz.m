%STEPZ  Multirate filter step response.
%   [H,T] = STEPZ(Hm) returns the step response H of the multirate filter
%   Hm. The length of column vector H is the length of the impulse
%   response. The vector of time samples at which H is evaluated is
%   returned in vector T.
%
%   [H,T] = STEPZ(Hm) returns a matrix H if Hm is a vector.  Each column of
%   the matrix corresponds to each filter in the vector. 
%
%   STEPZ(Hm) display the step response in the Filter Visualization Tool
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
%   For additional parameters, see SIGNAL/STEPZ.
%  
%   See also MFILT/IMPZ, MFILT/FREQZ.

%   Author: P. Costa
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2004/04/12 23:24:59 $

% Help for the p-coded STEPZ method of MFILT classes.
