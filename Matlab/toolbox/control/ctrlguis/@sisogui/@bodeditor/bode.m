function [m,p,w,Focus,SoftFocus] = bode(Editor,sys)
%BODE  Computes frequency range and grid for Bode plot.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $ $Date: 2004/04/10 23:14:04 $

%   RE: Wrapper around GENFRESP. For single SISO model only.

% REVISIT: work around dispatch problems
sys = sys{1};

% Compute grid and response
[m,p,w,FocusInfo] = genfresp(sys,3,[]);
p = (180/pi) * p;

% Eliminate NaN/Inf values near w=0 (due to integrators)
idx = find(cumsum(isfinite(m))>0);
w = w(idx);  m = m(idx);  p = p(idx);

% Focus data
Focus = FocusInfo.Range(3,:);
SoftFocus = FocusInfo.Soft;
