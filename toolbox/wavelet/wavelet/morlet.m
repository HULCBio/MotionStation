function [out1,out2] = morlet(LB,UB,N,flagGUI)
%MORLET Morlet wavelet.
%   [PSI,X] = MORLET(LB,UB,N) returns values of 
%   the Morlet wavelet on an N point regular grid 
%   in the interval [LB,UB].
%   Output arguments are the wavelet function PSI
%   computed on the grid X, and the grid X.
%
%   This wavelet has [-4 4] as effective support.
%
%   See also WAVEINFO.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.12.4.2 $

% Compute values of the Morlet wavelet.
out2 = linspace(LB,UB,N);        % wavelet support.
out1 = exp(-(out2.^2)/2) .* cos(5*out2);
