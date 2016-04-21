%SS  Discrete-time filter to state-space conversion.
%   [A,B,C,D] = SS(Hd) converts discrete-time filter Hd to state-space
%   representation given by 
%     x(k+1) = A*x(k) + B*u(k)
%     y(k)   = C*x(k) + D*u(k)
%   where x is the state vector, u is the input vector, and y is the output
%   vector. 

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/10/29 20:38:35 $

% Help for the p-coded SS method of DFILT classes.
