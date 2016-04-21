%ZEROPHASE Discrete-time filter zero-phase response.
%   [Hr,W] = ZEROPHASE(Hd,N) returns length N vectors Hr and W containing
%   the zero-phase response of the discrete-time filter Hd, and the
%   frequencies (in radians) at which it is evaluated. The zero-phase
%   response is evaluated at N points equally spaced around the upper half
%   of the unit circle.  For an FIR filter where N is a power of two, the
%   computation is done faster using FFTs.  If you don't specify N, it
%   defaults to 8192.
%
%   [Hr,W] = ZEROPHASE(Hd) returns a matrix Hr if Hd is a vector.  Each
%   column of the matrix corresponds to each filter in the vector.  If a
%   row vector of frequency points is specified, each row of the matrix
%   corresponds to each filter in the vector.
%
%   For additional parameters, see SIGNAL/ZEROPHASE.

%   Author: V. Pellissier, J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/10/29 20:38:37 $

% Help for the p-coded ZEROPHASE method of DFILT classes.
