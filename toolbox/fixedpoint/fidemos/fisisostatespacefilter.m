function [y,z] = fisisostatespacefilter(A,B,C,D,x,z)
%FISISOSTATESPACEFILTER Single-input, single-output statespace filter
% [Y,Zf] = FISISOSTATESPACEFILTER(A,B,C,D,X,Zi) filters data X with
% initial conditions Zi with the state-space filter defined by matrices
% A, B, C, D.  Output Y and final conditions Zf are returned.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $

y = x; 
z(:,2:length(x)+1) = 0;
for k=1:length(x)
  y(k)     = C*z(:,k) + D*x(k);
  z(:,k+1) = A*z(:,k) + B*x(k);
end