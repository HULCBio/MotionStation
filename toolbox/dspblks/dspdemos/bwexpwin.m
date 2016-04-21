function y = bwexpwin(N,alpha)
%BWEXPWIN Bandwidth expansion window.
%   BWEXPWIN(N,ALPHA) returns the N-point bandwidth expansion window
%   in a column vector.  ALPHA the bandwidth expansion parameter
%   should be in the range [0,1].
%   
%   The generated window when multiplied with the autoregressive (AR) 
%   polynomial coefficients expands (flattens) its spectral peaks.
%   The radius of the roots in the AR polynomial are scaled towards the
%   origin in the Z-plane. The window coefficients are 
%   [1 ALPHA ALPHA^2 ALPHA^3 ... ALPHA^(N-1)].
%  
%   See also POLYSCALE, WINDOW.

%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:05:36 $

y = alpha .^ (0:N-1);

% [EOF] bwexpwin.m
