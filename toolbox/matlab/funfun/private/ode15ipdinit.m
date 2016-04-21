function [Jac,dfdy,dfdyp,Jconstant,dfdy_options,dfdyp_options,nfcn] = ... 
    ode15ipdinit(odefun,t0,y0,yp0,f0,options,extras)
%ODE15IPDINIT  Helper function for initializing partial derivatives in ODE15I
%   Input arguments are the corresponding arguments of ODE15I and F0 is 
%   the value of ODEFUN(T0,Y0,YP0,EXTRAS{:}).
%   DFDY and DFDYP are the partial derivatives of ODEFUN(T0,Y0,YP0).
%   JAC is set to the Jacobian function specified in OPTIONS. JAC = [] if 
%   no Jacobian function has been supplied through OPTIONS.
%   JCONSTANT is TRUE if both DFDY and DFDYP are constant.
%   DFDY_ and DFDYP_OPTIONS are structures with properties for ODENUMJAC.
%   NFCN is the number of ODEFUN function evaluations.
%
%   See also ODE15I, DECIC, ODENUMJAC, ODE15IPDUPDATE.

%   Jacek Kierzenka
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/16 22:06:45 $

Jac = odeget(options,'Jacobian',{[],[]},'fast');
% Jac could be set to {dfdy,dfdyp} or to a function returning [dfdy,dfdyp]. 
% dfdy or/and dfdyp could be empty.

Jconstant = strcmp(odeget(options,'JConstant','off','fast'),'on'); 
if iscell(Jac)
  dfdy  = Jac{1};  % may be empty
  dfdyp = Jac{2};  % may be empty
  Jac = [];   % let ODE15I know that there is no Jacobian function
  Jconstant = Jconstant || (~isempty(dfdy) && ~isempty(dfdyp));
else   % Jac should be a function
  [dfdy,dfdyp] = feval(Jac,t0,y0,yp0,extras{:});  
end

dfdyNumerical  = isempty(dfdy);
dfdypNumerical = isempty(dfdyp);      

dfdy_options = [];
dfdyp_options = [];
nfcn = 0;
if dfdyNumerical || dfdypNumerical  
  vectorized = odeget(options,'Vectorized',{'off','off'},'fast');
  if ~iscell(vectorized)
    vectorized = {vectorized,vectorized};
  end
  atol = odeget(options,'AbsTol',1e-6,'fast');
  Jthresh = zeros(size(y0))+ atol(:);
  Jpattern = odeget(options,'JPattern',{[],[]},'fast');   
  if dfdyNumerical
    dfdy_options.diffvar = 2;    % df(t,y,yp)/dy
    dfdy_options.vectvars = [];
    if strcmp(vectorized{1},'on');
      dfdy_options.vectvars = 2;
    end      
    dfdy_options.thresh = Jthresh;
    dfdy_options.fac = [];
    if ~isempty(Jpattern{1})
      dfdy_options.pattern = Jpattern{1};          
      dfdy_options.g = colgroup(Jpattern{1});  % numjac column grouping
    end  
  end
  if dfdypNumerical    
    dfdyp_options.diffvar = 3;
    dfdyp_options.vectvars = [];
    if strcmp(vectorized{2},'on');
      dfdyp_options.vectvars = 3;
    end      
    dfdyp_options.thresh = Jthresh;
    dfdyp_options.fac = []; 
    if ~isempty(Jpattern{2}) 
      dfdyp_options.pattern = Jpattern{2};    
      dfdyp_options.g = colgroup(Jpattern{2});  % numjac column grouping
    end  
  end
  
  % Evaluate the numerical derivatives. Pass Jac = [] to ensure 
  % that only the numerical approximations get evaluated.
  [dfdy,dfdyp,dfdy_options,dfdyp_options,nfcn] = ...
      ode15ipdupdate([],odefun,t0,y0,yp0,f0,dfdy,dfdyp,dfdy_options,dfdyp_options,extras); 
  
end
