function status = odeprint(t,y,flag,varargin)
%ODEPRINT  Command window printing ODE output function.
%   When the function odeprint is passed to an ODE solver as the 'OutputFcn'
%   property, i.e. options = odeset('OutputFcn',@odeprint), the solver calls 
%   ODEPRINT(T,Y,'') after every timestep. The ODEPRINT function prints all 
%   components of the solution it is passed as it is computed. To print only 
%   particular components, specify their indices in the 'OutputSel' property 
%   passed to the ODE solver.
%   
%   At the start of integration, a solver calls ODEPRINT(TSPAN,Y0,'init') to
%   initialize the output function.  After each integration step to new time
%   point T with solution vector Y the solver calls STATUS = ODEPRINT(T,Y,'').
%   If the solver's 'Refine' property is greater than one (see ODESET), then
%   T is a column vector containing all new output times and Y is an array
%   comprised of corresponding column vectors.  ODEPRINT always returns
%   STATUS = 0.  When the integration is complete, the solver calls
%   ODEPRINT([],[],'done').
%
%   When an ODE solver is called with additional input parameters, for example
%   ODE45(ODEFUN,TSPAN,Y0,OPTIONS,P1,P2...), the solver passes the parameters
%   to the output function, for example ODEPRINT(T,Y,'',P1,P2...).  
%   
%   See also ODEPLOT, ODEPHAS2, ODEPHAS3, ODE45, ODE15S, ODESET.

%   Mark W. Reichelt and Lawrence F. Shampine, 3-24-94
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.17.4.2 $  $Date: 2004/04/16 22:05:35 $

if nargin < 3 || isempty(flag) % odeprint(t,y) [v5 syntax] or odeprint(t,y,'')
  
  clc
  t  
  y 
    
else
  switch(flag)
  case 'init'               % odeprint(tspan,y0,'init')

    clc
    t = t(1)
    y 
    
  case 'done'               % odeprint([],[],'done')
  
    fprintf('\n\n');
    
  end
end

status = 0;
