function pi = polyint(p,k)
%POLYINT Integrate polynomial analytically.
%   POLYINT(P,K) returns a polynomial representing the integral
%   of polynomial P, using a scalar constant of integration K.
%
%   POLYINT(P) assumes a constant of integration K=0.
%
%   Class support for inputs p, k:
%      float: double, single
%
%   See also POLYDER, POLYVAL, POLYVALM, POLYFIT.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2004/03/02 21:47:58 $

if nargin<2, k=0; end
pi = [p./(length(p):-1:1) k];

% [EOF] polyint.m
