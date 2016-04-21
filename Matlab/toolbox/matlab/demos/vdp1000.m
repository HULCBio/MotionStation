function dydt = vdp1000(t,y)
%VDP1000  Evaluate the van der Pol ODEs for mu = 1000.
%
%   See also ODE15S, ODE23S, ODE23T, ODE23TB.

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/15 03:30:34 $

dydt = [y(2); 1000*(1-y(1)^2)*y(2)-y(1)];
