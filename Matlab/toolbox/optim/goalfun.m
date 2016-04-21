function [lambda,gf]=goalfun(V,neqcstr,FUNfcns,GRADfcns,WEIGHT,GOAL,x,varargin)
%GOALFUN Utility function to translate goal-attainment problem.
%
%   Intermediate function used to translate goal attainment
%   problem into constrained optimization problem.
%   Used by FGOALATTAIN, FMINIMAX and FMINCON (from private/NLCONST). 
%   
%   See also GOALCON.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.18.4.1 $  $Date: 2004/02/07 19:13:12 $
%   Andy Grace 7-9-90.

nx=length(V)-1;
% Assign V to x, keeping x to be its original length and width
x(:)=V(1:nx);

% Compute the objective function 
lambda=V(nx+1);   

if nargout > 1
   % Compute the gradient of the objective
   gf=[zeros(nx,1); 1];
end
