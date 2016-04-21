%PHASEZ Instantaneous adaptive filter phase response (unwrapped).
%   [Phi,W] = PHASEZ(Hd,N) returns vectors Phi and W containing the
%   instantaneous phase response of the adaptive filter Hd, and the
%   frequencies (in radians) at which it is evaluated. The phase response
%   is evaluated at N points equally spaced around the upper half of the
%   unit circle. If N is not specified, it defaults to 8192.
%
%   If Hd is a vector of filter objects, Phi becomes a matrix.  Each column
%   of the matrix corresponds to each filter in the vector.  If a row
%   vector of frequency points is specified, each row of the matrix
%   corresponds to each filter in the vector.
%
%   PHASEZ(Hd) display the phase response in the Filter Visualization Tool
%   (FVTool).
%
%   For additional parameters, see SIGNAL/PHASEZ.

%   Author: V. Pellissier
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/10/30 14:53:56 $

% Help for the p-coded PHASEZ method of ADAPTFILT classes.
