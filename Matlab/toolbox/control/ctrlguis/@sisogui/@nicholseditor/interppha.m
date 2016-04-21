function [index, alpha] = interppha(Editor, X, Xi)
%INTERPPHA  Interpolates phase data:
%           Given X = X(n), find (index) and (alpha) such that
%           Xi =  (1-alpha) * X(index) + alpha * X(index+1).
%           X and XI are expressed in linear units (deg or rad).

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $ $Date: 2002/04/10 05:05:31 $

% length of data
np = length(X);

% Length of data intervals
dX  = X(2:np) - X(1:np-1);
dXi = Xi      - X(1:np-1);

% Find indices (k's) such that Xi is in [X(k), X(k+1)] 
% REMARK: Prevent 0's in dX.
ratio = dXi ./ (dX + eps*(~dX));
index = find((ratio >=0) & (ratio <= 1)); % Use >= and <= to include end points

% Iterpolation coefficients
% Xi =  (1-alpha) * X(index) + alpha * X(index+1).
alpha = ratio(index);
