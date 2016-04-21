function [dfdy,dfdyp,dfdy_options,dfdyp_options,nfcn] = ...
      ode15ipdupdate(Jac,odefun,t,y,yp,f,dfdy,dfdyp,dfdy_options,dfdyp_options,extras)
%ODE15IPDUPDATE  Helper function for updating partial derivatives in ODE15I
%   The input argument JAC is the user supplied Jacobian function or [].
%   ODEFUN is the ODE function, F(t,y,yp). T,Y,YP are the current arguments, 
%   and F is the value of ODEFUN(T,Y,YP,EXTRAS{:}).
%   DFDY and DFDYP are the current values of the partial derivatives.
%   An empty DFDY_OPTIONS indicates that the derivative DFDY is constant. 
%   In such case ODE15IPDUPDATE simply returns the values of input arguments,
%   DFDY and DFDY_OPTIONS (siimilarly for DFDYP and DFDYP_OPTIONS.)
%
%   Note that a call to ODENUMJAC changes both the derivative (DFDY,DFDYP) 
%   and the options structure (DFDY_OPTIONS,DFDYP_OPTIONS).
%
%   See also ODE15I, DECIC, ODENUMJAC, ODE15IPDINIT.

%   Jacek Kierzenka
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/16 22:06:46 $

if ~isempty(Jac)
  [dfdy,dfdyp] = feval(Jac,t,y,yp,extras{:});    
end
nfcn = 0;
if ~isempty(dfdy_options)  
  [dfdy,dfdy_options.fac,NF] = odenumjac(odefun,{t,y,yp,extras{:}},f,dfdy_options);  
  nfcn = nfcn + NF;    
end
if ~isempty(dfdyp_options)
  [dfdyp,dfdyp_options.fac,NF] = odenumjac(odefun,{t,y,yp,extras{:}},f,dfdyp_options);  
  nfcn = nfcn + NF;    
end
