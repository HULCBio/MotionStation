function varargout = powerest(this,x,Fs)
%POWEREST   Computes the powers and frequencies of sinusoids.
%   POW = POWEREST(H,X) returns the vector POW containing the estimates
%   of the powers of the complex sinusoids contained in the data
%   represented by X.  H must be a MUSIC or EIGENVECTOR object. 
%
%   X can be a vector or a matrix. If it's a vector it is a signal, if
%   it's a matrix it may be either a data matrix such that X'*X=R, or a
%   correlation matrix R.  How X is interpreted depends on the value of the
%   spectrum object's (H) InputType property, which can be any one of the
%   following:
%        Vector
%        DataMatrix
%        CorrelationMatrix
%
%   [POW,W] = POWEREST(...) returns in addition a vector of frequencies W
%   of the sinusoids contained in X.  W is in units of rad/sample.
%
%   [POW,F] = POWEREST(...,Fs) uses the sampling frequency Fs in the
%   computation and returns the vector of frequencies, F, in Hz.
%
%   EXAMPLES:
%      randn('state',1); n = 0:99;   
%      s = exp(i*pi/2*n)+2*exp(i*pi/4*n)+exp(i*pi/3*n)+randn(1,100);  
%      H = spectrum.music(3);
%      [P,W] = powerest(H,s);
%   
%   See also SPECTRUM/MUSIC, SPECTRUM/EIGENVECTOR, SPECTRUM/PSEUDOSPECTRUM. 

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/12/06 16:10:56 $

% Help for powerest.m

% [EOF]
