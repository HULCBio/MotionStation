function k = scalingfactor(x,v,Tp)
%SCALINGFACTOR - returns the two scaling factors necessary for vector window preprocessor
% K=SCALINGFACTOR(X,V,TP) accepts the position and velocity of the initial vector
%   X(1) and V(1) and computes the necessary scaling factors to create a smoothed
%   transition to the target vector X(2) and V(2).

%   Author(s): A. Dowd
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 01:19:45 $
if length(x) < 2,
    error('X parameter requires initial ''x(0)'' and target ''x(1)'' positions');
elseif length(v) <2,
    error('V parameter requires initial ''v(0)'' and target ''v(1)'' velocities');
end
if ~isnumeric(x),
    error('X parameter (position values) must be a numeric vector');
elseif ~isnumeric(v),
    error('V parameter (velocity values) must be a numeric vector');
elseif ~isnumeric(Tp),
     error('TP parameter (Transition period) must be a numeric value'); 
end
k(1) = v(2) - v(1);
k(2) = x(2) - x(1) - ((v(2) + v(1))*Tp)/2;

% [EOF] scalingfactor.m