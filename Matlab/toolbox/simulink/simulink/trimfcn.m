function [f,g]=trimfcn(DES,fcn,t,x0,u0,y0,ix,iu,iy,dx0,idx)
%TRIMFCN Used as a gateway to the optimization routine SIMCNSTR
%   This function is used in trimming.
%
%   See also TRIM.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.9 $
%   Andrew Grace 11-12-90.
%   Revised: Marc Ullman 8-26-96

nx=length(x0);
x = DES(1:nx);
u = DES(nx+1:nx+length(u0));
lambda = DES(length(DES));

%
% Get derivatives and outputs from system.
%
y  = feval(fcn, t, x, u, 'outputs');
dx = feval(fcn, t, x, u, 'derivs');

%
% Form constraints that minimize deviation from intended values.
%
gg=[x(ix)-x0(ix);y(iy)-y0(iy);u(iu)-u0(iu)];
g =[dx(idx)-dx0(idx); gg-lambda; -gg-lambda];

%
% Objective function is just lambda.
%
f=lambda;

% end trimfcn