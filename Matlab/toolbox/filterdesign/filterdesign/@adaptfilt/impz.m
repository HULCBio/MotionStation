%IMPZ  Instantaneous adaptive filter impulse response.
%   [H,T] = IMPZ(Hadapt) computes the impulse response of the adaptive
%   filter Hadapt and returns the response in column vector H and a vector of 
%   times (or sample intervals) in T (T = [0 1 2...]').  By default the number of 
%   samples computed is the length of the filter.
%
%   [H,T] = IMPZ(Hadapt) returns a matrix H if Hadapt is a vector.  Each 
%   column of the matrix corresponds to each filter in the vector. 
%
%   For additional parameters, see SIGNAL/IMPZ.
%
%   See also SIGNAL/IMPZ, ADAPTFILT/STEPZ, ADAPTFILT/FREQZ, ADAPTFILT/ZPLANE.

%   Author(s): P. Costa
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/10/30 21:50:00 $

% Help for the filter's pcoded IMPZ method.

% [EOF]
