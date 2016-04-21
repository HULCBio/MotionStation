function dydt = vanderpoldemo(t,y,Mu)
%VANDERPOLDEMO Defines the van der Pol equation for ODEDEMO.

% Copyright 1984-2002 The MathWorks, Inc.  
% $Revision: 1.2 $  $Date: 2002/06/17 13:20:38 $ 

dydt = [y(2); Mu*(1-y(1)^2)*y(2)-y(1)];