function dydt = vdp1(t,y)
%VDP1  Evaluate the van der Pol ODEs for mu = 1
%
%   See also ODE113, ODE23, ODE45.

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/15 03:30:32 $

dydt = [y(2); (1-y(1)^2)*y(2)-y(1)];
