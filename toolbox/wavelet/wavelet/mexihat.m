function [out1,out2] = mexihat(LB,UB,N,flagGUI)
%MEXIHAT Mexican hat wavelet.
%   [PSI,X] = MEXIHAT(LB,UB,N) returns values of 
%   the Mexican hat wavelet on an N point regular
%   grid in the interval [LB,UB].
%   Output arguments are the wavelet function PSI
%   computed on the grid X.
%
%   This wavelet has [-5 5] as effective support.
%
%   See also WAVEINFO.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.12.4.2 $

% Compute values of the Mexican hat wavelet.
out2 = linspace(LB,UB,N);        % wavelet support.
out1 = out2.^2;
out1 = (2/(sqrt(3)*pi^0.25)) * exp(-out1/2) .* (1-out1);

