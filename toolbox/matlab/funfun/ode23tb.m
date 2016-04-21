function varargout = ode23tb(ode,tspan,y0,options,varargin)
%ODE23TB Solve stiff differential equations, low order method.
%   [T,Y] = ODE23TB(ODEFUN,TSPAN,Y0) with TSPAN = [T0 TFINAL] integrates the
%   system of differential equations y' = f(t,y) from time T0 to TFINAL with
%   initial conditions Y0. Function ODEFUN(T,Y) must return a column vector
%   corresponding to f(t,y). Each row in the solution array Y corresponds to
%   a time returned in the column vector T. To obtain solutions at specific
%   times T0,T1,...,TFINAL (all increasing or all decreasing), use 
%   TSPAN = [T0 T1 ... TFINAL].     
%   
%   [T,Y] = ODE23TB(ODEFUN,TSPAN,Y0,OPTIONS) solves as above with default
%   integration parameters replaced by values in OPTIONS, an argument created
%   with the ODESET function. See ODESET for details. Commonly used options
%   are scalar relative error tolerance 'RelTol' (1e-3 by default) and vector
%   of absolute error tolerances 'AbsTol' (all components 1e-6 by default).
%      
%   [T,Y] = ODE23TB(ODEFUN,TSPAN,Y0,OPTIONS,P1,P2...) passes the additional
%   parameters P1,P2,... to the ODE function as ODEFUN(T,Y,P1,P2...), and to
%   all functions specified in OPTIONS. Use OPTIONS = [] as a place holder if
%   no options are set. 
%   
%   The Jacobian matrix df/dy is critical to reliability and efficiency. Use
%   ODESET to set 'Jacobian' to a function FJAC if FJAC(T,Y) returns the
%   Jacobian df/dy or to the matrix df/dy if the Jacobian is constant. If the
%   'Jacobian'option is not set (the default), df/dy is approximated by
%   finite differences. Set 'Vectorized' 'on' if the ODE function is coded so
%   that ODEFUN(T,[Y1 Y2 ...]) returns [ODEFUN(T,Y1) ODEFUN(T,Y2) ...]. If
%   df/dy is a sparse matrix, set 'JPattern' to the sparsity pattern of
%   df/dy, i.e., a sparse matrix S with S(i,j) = 1 if component i of f(t,y)
%   depends on component j of y, and 0 otherwise.    
%   
%   ODE23TB can solve problems M(t,y)*y' = f(t,y) with mass matrix M(t,y)
%   that is nonsingular. Use ODESET to set the 'Mass' property to a function
%   MASS if MASS(T,Y) returns the value of the mass matrix. If the mass
%   matrix is constant, the matrix can be used as the value of the 'Mass'
%   option. Problems with state-dependent mass matrices are more
%   difficult. If the mass matrix does not depend on the state variable Y and
%   the function MASS is to be called with one input argument T, set
%   'MStateDependence' to 'none'. If the mass matrix depends weakly on Y, set
%   'MStateDependence' to 'weak' (the default) and otherwise, to 'strong'. In
%   either case the function MASS is to be called with the two arguments
%   (T,Y). If there are many differential equations, it is important to
%   exploit sparsity: Return a sparse M(t,y). Either supply the sparsity
%   pattern of df/dy using the 'JPattern' property or a sparse df/dy using
%   the Jacobian property. For strongly state-dependent M(t,y), set
%   'MvPattern' to a sparse matrix S with S(i,j) = 1 if for any k, the (i,k)
%   component of M(t,y) depends on component j of y, and 0 otherwise. ODE15S
%   and ODE23T can solve problems with singular mass matrices. 
%   
%   [T,Y,TE,YE,IE] = ODE23TB(ODEFUN,TSPAN,Y0,OPTIONS...) with the 'Events'
%   property in OPTIONS set to a function EVENTS, solves as above while also
%   finding where functions of (T,Y), called event functions, are zero. For
%   each function you specify whether the integration is to terminate at a
%   zero and whether the direction of the zero crossing matters. These are
%   the three vectors returned by EVENTS: [VALUE,ISTERMINAL,DIRECTION] =
%   EVENTS(T,Y). For the I-th event function: VALUE(I) is the value of the
%   function, ISTERMINAL(I)=1 if the integration is to terminate at a zero of
%   this event function and 0 otherwise. DIRECTION(I)=0 if all zeros are to
%   be computed (the default), +1 if only zeros where the event function is
%   increasing, and -1 if only zeros where the event function is
%   decreasing. Output TE is a column vector of times at which events
%   occur. Rows of YE are the corresponding solutions, and indices in vector
%   IE specify which event occurred.    
%
%   SOL = ODE23TB(ODEFUN,[T0 TFINAL],Y0...) returns a structure that can be
%   used with DEVAL to evaluate the solution or its first derivative at 
%   any point between T0 and TFINAL. The steps chosen by ODE23TB are returned 
%   in a row vector SOL.x.  For each I, the column SOL.y(:,I) contains 
%   the solution at SOL.x(I). If events were detected, SOL.xe is a row vector 
%   of points at which events occurred. Columns of SOL.ye are the corresponding 
%   solutions, and indices in vector SOL.ie specify which event occurred. 
%   
%   Example
%         [t,y]=ode23tb(@vdp1000,[0 3000],[2 0]);   
%         plot(t,y(:,1));
%     solves the system y' = vdp1000(t,y), using the default relative error
%     tolerance 1e-3 and the default absolute tolerance of 1e-6 for each
%     component, and plots the first component of the solution.
%
%   See also 
%     other ODE solvers:    ODE15S, ODE23S, ODE23T, ODE45, ODE23, ODE113
%     options handling:     ODESET, ODEGET
%     output functions:     ODEPLOT, ODEPHAS2, ODEPHAS3, ODEPRINT
%     evaluating solution:  DEVAL
%     ODE examples:         VDPODE, FEM1ODE, BRUSSODE
%
%   NOTE: 
%     The interpretation of the first input argument of the ODE solvers and
%     some properties available through ODESET have changed in this version
%     of MATLAB. Although we still support the v5 syntax, any new
%     functionality is available only with the new syntax. To see the v5
%     help type in the command line 
%         more on, type ode23tb, more off

%   NOTE:
%     This portion describes the v5 syntax of ODE23TB.
%
%   [T,Y] = ODE23TB('F',TSPAN,Y0) with TSPAN = [T0 TFINAL] integrates the
%   system of differential equations y' = F(t,y) from time T0 to TFINAL with
%   initial conditions Y0.  'F' is a string containing the name of an ODE
%   file.  Function F(T,Y) must return a column vector.  Each row in
%   solution array Y corresponds to a time returned in column vector T.  To
%   obtain solutions at specific times T0, T1, ..., TFINAL (all increasing
%   or all decreasing), use TSPAN = [T0 T1 ... TFINAL].
%   
%   [T,Y] = ODE23TB('F',TSPAN,Y0,OPTIONS) solves as above with default
%   integration parameters replaced by values in OPTIONS, an argument
%   created with the ODESET function.  See ODESET for details.  Commonly
%   used options are scalar relative error tolerance 'RelTol' (1e-3 by
%   default) and vector of absolute error tolerances 'AbsTol' (all
%   components 1e-6 by default).
%   
%   [T,Y] = ODE23TB('F',TSPAN,Y0,OPTIONS,P1,P2,...) passes the additional
%   parameters P1,P2,... to the ODE file as F(T,Y,FLAG,P1,P2,...) (see
%   ODEFILE).  Use OPTIONS = [] as a place holder if no options are set.
%   
%   It is possible to specify TSPAN, Y0 and OPTIONS in the ODE file (see
%   ODEFILE).  If TSPAN or Y0 is empty, then ODE23TB calls the ODE file
%   [TSPAN,Y0,OPTIONS] = F([],[],'init') to obtain any values not supplied
%   in the ODE23TB argument list.  Empty arguments at the end of the call
%   list may be omitted, e.g. ODE23TB('F').
%   
%   The Jacobian matrix dF/dy is critical to reliability and efficiency.
%   Use ODESET to set JConstant 'on' if dF/dy is constant.  Set Vectorized
%   'on' if the ODE file is coded so that F(T,[Y1 Y2 ...]) returns
%   [F(T,Y1) F(T,Y2) ...].  Set JPattern 'on' if dF/dy is a sparse matrix
%   and the ODE file is coded so that F([],[],'jpattern') returns a sparsity
%   pattern matrix of 1's and 0's showing the nonzeros of dF/dy.  Set
%   Jacobian 'on' if the ODE file is coded so that F(T,Y,'jacobian') returns
%   dF/dy.
%   
%   ODE23TB can solve problems M(t,y)*y' = F(t,y) with a mass matrix M that
%   is nonsingular.  Use ODESET to set Mass to 'M', 'M(t)', or 'M(t,y)' if
%   the ODE file is coded so that F(T,Y,'mass') returns a constant,
%   time-dependent, or time- and state-dependent mass matrix, respectively.
%   The default value of Mass is 'none'. 
%   ODE15S and ODE23T can solve problems with singular mass matrices.
%   
%   [T,Y,TE,YE,IE] = ODE23TB('F',TSPAN,Y0,OPTIONS) with the Events property
%   in OPTIONS set to 'on', solves as above while also locating zero
%   crossings of an event function defined in the ODE file.  The ODE file
%   must be coded so that F(T,Y,'events') returns appropriate information.
%   See ODEFILE for details.  Output TE is a column vector of times at which
%   events occur, rows of YE are the corresponding solutions, and indices in
%   vector IE specify which event occurred.
%   
%   See also ODEFILE

%   ODE23TB is an implementation of TR-BDF2, an implicit Runge-Kutta 
%   formula with a first stage that is a trapezoidal rule (TR) step and 
%   a second stage that is a backward differentiation formula (BDF) of 
%   order two.  By construction, the same iteration matrix is used in 
%   evaluating both stages.  The formula was proposed by Bank and Rose.
%   Here the improved error estimator and more efficient evaluation of
%   M. Hosea and L.F. Shampine are used.  A "free" interpolant is used.

%   Mark W. Reichelt, Lawrence F. Shampine, and Yanyuan Ma, 7-1-97
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.25.4.3 $  $Date: 2003/05/19 11:15:50 $

solver_name = 'ode23tb';

if nargin < 4
  options = [];
  if nargin < 3
    y0 = [];
    if nargin < 2
      tspan = [];
      if nargin < 1
        error('MATLAB:ode23tb:NotEnoughInputs',...
              'Not enough input arguments.  See ODE23tb.');
      end  
    end
  end
end

% Stats
nsteps   = 0;
nfailed  = 0;
nfevals  = 0; 
npds     = 0;
ndecomps = 0;
nsolves  = 0;

% Output
FcnHandlesUsed  = isa(ode,'function_handle');
output_sol = (FcnHandlesUsed && (nargout==1));      % sol = odeXX(...)
output_ty  = (~output_sol && (nargout > 0));  % [t,y,...] = odeXX(...)
% There might be no output requested...

sol = []; t2data = []; y2data = []; 
if output_sol
  sol.solver = solver_name;
  sol.extdata.odefun = ode;
  sol.extdata.options = options;                       
  sol.extdata.varargin = varargin;  
end  
odeFcn = ode;

% Handle solver arguments
[neq, tspan, ntspan, next, t0, tfinal, tdir, y0, f0, odeArgs, ...
 options, threshold, rtol, normcontrol, normy, hmax, htry, htspan]  ...
    = odearguments(FcnHandlesUsed, solver_name, odeFcn, tspan, y0,  ...
                   options, varargin);
nfevals = nfevals + 1;

% Handle the output 
if nargout > 0
  outputFcn = odeget(options,'OutputFcn',[],'fast');
else
  outputFcn = odeget(options,'OutputFcn',@odeplot,'fast');
end
outputArgs = {};      
if isempty(outputFcn)
  haveOutputFcn = false;
else
  haveOutputFcn = true;
  outputs = odeget(options,'OutputSel',1:neq,'fast');
  if isa(outputFcn,'function_handle') 
    % With MATLAB 6 syntax pass additional input arguments to outputFcn.
    outputArgs = varargin;
  end  
end
refine = max(1,odeget(options,'Refine',1,'fast'));
if ntspan > 2
  outputAt = 'RequestedPoints';         % output only at tspan points
elseif refine <= 1
  outputAt = 'SolverSteps';             % computed points, no refinement
else
  outputAt = 'RefinedSteps';            % computed points, with refinement
  S = (1:refine-1) / refine;
end
printstats = strcmp(odeget(options,'Stats','off','fast'),'on');

% Handle the event function 
[haveEventFcn,eventFcn,eventArgs,valt,teout,yeout,ieout] = ...
    odeevents(FcnHandlesUsed,odeFcn,t0,y0,options,varargin);

% Handle the mass matrix
[Mtype, Mfun, Margs, Mt, dMoptions] = odemass(FcnHandlesUsed,odeFcn,t0,y0,...
                                              options,varargin);
if Mtype > 0
  Msingular = odeget(options,'MassSingular','no','fast');
  if strcmp(Msingular,'maybe')
    warning('MATLAB:ode23tb:MassSingularAssumedNo',['ODE23TB assumes ' ...
            'MassSingular is ''no''. See ODE15S or ODE23T.']);
  elseif strcmp(Msingular,'yes')
    error('MATLAB:ode23tb:MassSingularYes',...
          ['MassSingular cannot be ''yes'' for ODE23TB. See ODE15S or ' ...
          'ODE23T.']);
  end 
end

% Handle the Jacobian
[Jconstant,Jac,Jargs,Joptions] = ...
    odejacobian(FcnHandlesUsed,odeFcn,t0,y0,options,varargin);
Janalytic = isempty(Joptions);

% if not set via 'options', initialize constant Jacobian here
if Jconstant 
  if isempty(Jac) % use odenumjac
    [Jac,Joptions.fac,nF] = odenumjac(odeFcn, {t0,y0,odeArgs{:}}, f0, Joptions);  
    nfevals = nfevals + nF;
    npds = npds + 1;
  elseif ~isa(Jac,'numeric')  % not been set via 'options'  
    Jac = feval(Jac,t0,y0,Jargs{:}); % replace by its value
    npds = npds + 1;
  end
end

t = t0;
y = y0;

Mcurrent = true;
Mt2 = Mt;
Mtnew = Mt;

% Initialize method parameters.
pow = 1/3;
alpha = 2 - sqrt(2);
d = alpha/2;
gg = sqrt(2)/4;

% Coefficients of the error estimate.
c1 = (alpha - 1)/3;
c2 = 1/3;
c3 = -alpha/3;

% Coefficients for the predictors
p31 = 1.5 + sqrt(2);
p32 = 2.5 + 2*sqrt(2);
p33 = - (6 + 4.5*sqrt(2));

% Compute the initial slope yp.
if Mtype > 0
  [L,U] = lu(Mt);
  yp = U \ (L \ f0);
  ndecomps = ndecomps + 1;              
  nsolves = nsolves + 1;                
else
  yp = f0;
end

if Jconstant
  dfdy = Jac;
elseif Janalytic
  dfdy = feval(Jac,t,y,Jargs{:});     
  npds = npds + 1;                            
else  
  [dfdy,Joptions.fac,nF] = odenumjac(odeFcn, {t,y,odeArgs{:}}, f0, Joptions);    
  nfevals = nfevals + nF;    
  npds = npds + 1;                            
end    

Jcurrent = true;
needNewJ = false;

% hmin is a small number such that t + hmin is clearly different from t in
% the working precision, but with this definition, it is 0 if t = 0.
hmin = 16*eps*abs(t);

if isempty(htry)
  % Compute an initial step size h using yp = y'(t).
  if normcontrol
    wt = max(normy,threshold);
    rh = 1.43 * (norm(yp) / wt) / rtol^pow;  % 1.43 = 1 / 0.7
  else  
    wt = max(abs(y),threshold);
    rh = 1.43 * norm(yp ./ wt,inf) / rtol^pow;
  end
  absh = min(hmax, htspan);
  if absh * rh > 1
    absh = 1 / rh;
  end
  absh = max(absh, hmin);
  
  % Estimate error of first order Taylor series, 0.5*h^2*y''(t), 
  % and use rule of thumb to select step size for second order method.
  h = tdir * absh;
  tdel = (t + tdir*min(sqrt(eps)*max(abs(t),abs(t+h)),absh)) - t;
  f1 = feval(odeFcn,t+tdel,y,odeArgs{:});
  nfevals = nfevals + 1;                
  dfdt = (f1 - f0) ./ tdel;
  if normcontrol
    if Mtype > 0
      rh = 1.43*sqrt(0.5 * (norm(U \ (L \ (dfdt + dfdy*yp))) / wt)) / rtol^pow;
    else
      rh = 1.43 * sqrt(0.5 * (norm(dfdt + dfdy*yp) / wt)) / rtol^pow;
    end
  else
    if Mtype > 0
      rh = 1.43*sqrt(0.5*norm((U\(L\(dfdt + dfdy*yp))) ./ wt,inf)) / rtol^pow;
    else
      rh = 1.43 * sqrt(0.5 * norm((dfdt + dfdy*yp) ./ wt,inf)) / rtol^pow;
    end
  end
  absh = min(hmax, htspan);
  if absh * rh > 1
    absh = 1 / rh;
  end
  absh = max(absh, hmin);
else
  absh = min(hmax, max(hmin, htry));
end
h = tdir * absh;

% Allocate memory if we're generating output.
nout = 0;
tout = []; yout = [];
if nargout > 0
  if output_sol
    chunk = min(max(100,50*refine), refine+floor((2^12)/neq));      
    tout = zeros(1,chunk);
    yout = zeros(neq,chunk);
    t2data = zeros(1,chunk);
    y2data = zeros(neq,chunk);
  else      
    if ntspan > 2                         % output only at tspan points
      tout = zeros(1,ntspan);
      yout = zeros(neq,ntspan);
    else                                  % alloc in chunks
      chunk = min(max(100,50*refine), refine+floor((2^13)/neq));
      tout = zeros(1,chunk);
      yout = zeros(neq,chunk);
    end
  end  
  nout = 1;
  tout(nout) = t;
  yout(:,nout) = y;  
end

% Initialize the output function.
if haveOutputFcn
  feval(outputFcn,[t tfinal],y(outputs),'init',outputArgs{:});
end

% THE MAIN LOOP

z = h * yp;                             % z is the scaled derivative.
if Mtype == 4
  [dMzdy,dMoptions.fac] = odenumjac(@odemxv, {Mfun,t,y,z,Margs{:}}, Mt*z, ...
                                    dMoptions);       
end                                                  
needNewLU = true;                       % Initialize LU.
done = false;
while ~done
  
  hmin = 16*eps*abs(t);
  abshlast = absh;
  absh = min(hmax, max(hmin, absh));
  h = tdir * absh;
  
  % Stretch the step if within 10% of tfinal-t.
  if 1.1*absh >= abs(tfinal - t)
    h = tfinal - t;
    absh = abs(h);
    done = true;
  end
  
  if absh ~= abshlast
    z = (absh / abshlast) * z;
    needNewLU = true;
  end
  
  % LOOP FOR ADVANCING ONE STEP.
  nofailed = true;                      % no failed attempts
  while true                            % Evaluate the formula.
    
    if normcontrol
      wt = max(normy,threshold);
    else
      wt = max(abs(y),threshold);
    end    
    
    if needNewJ
      if Janalytic
        dfdy = feval(Jac,t,y,Jargs{:});
      else
        f0 = feval(odeFcn,t,y,odeArgs{:});        
        [dfdy,Joptions.fac,nF] = odenumjac(odeFcn, {t,y,odeArgs{:}}, f0, Joptions);    
        nfevals = nfevals + nF + 1; 
      end             
      npds = npds + 1;                  
      Jcurrent = true;
      needNewJ = false;
      needNewLU = true;
    end  
    if needNewLU
      if ~Mcurrent                      % possible only if state-dependent
        Mt = feval(Mfun,t,y,Margs{:});
        Mcurrent = true;
        if Mtype == 4
          [dMzdy,dMoptions.fac] = odenumjac(@odemxv, {Mfun,t,y,z,Margs{:}}, Mt*z, ...
                                            dMoptions);       
        end                          
      end
      Miter = Mt - (d*h)*dfdy;
      if Mtype == 4
        Miter = Miter + dMzdy;
      end        
      [L,U] = lu(Miter);
      ndecomps = ndecomps + 1;          
      rate = [];
      needNewLU = false;
    end
    
    % The first stage is a TR step from t to t2.
    t2 = t + alpha*h;
    y2 = y + alpha*z;
    z2 = z;
    
    % Mt2 is required in the RHS function evaluation.
    if Mtype == 2   % M(t)
      if FcnHandlesUsed
        Mt2 = feval(Mfun,t2,Margs{:}); 
      else
        Mt2 = feval(Mfun,t2,y2,Margs{:});
      end
    end

    [y2,z2,iter,itfail1,rate] = ...
        itsolve(Mt2,t2,y2,z2,d,h,L,U,odeFcn,odeArgs,rtol,wt,rate,...
                Mtype,Mfun,Margs);
    nfevals = nfevals + iter;           
    nsolves = nsolves + iter;           
    itfail2 = false;                    % make sure well-defined later
    if ~itfail1
      % The second stage is a step from t2 to tnew with BDF2.
      if normcontrol
        wt = max(wt,norm(y2));
      else
        wt = max(wt,abs(y2));
      end

      tnew = t + h;
      if done
        tnew = tfinal;   % Hit end point exactly.
      end
      znew = p31*z + p32*z2 + p33*(y2 - y);
      ynew = y + gg * (z + z2) + d * znew;
      
      % Mtnew is required in the RHS function evaluation.
      if Mtype == 2   % M(t)
        if FcnHandlesUsed
          Mtnew = feval(Mfun,tnew,Margs{:}); 
        else
          Mtnew = feval(Mfun,tnew,ynew,Margs{:});
        end
      end
      
      [ynew,znew,iter,itfail2,rate] = ...
          itsolve(Mtnew,tnew,ynew,znew,d,h,L,U,odeFcn,odeArgs,rtol,wt,rate,...
                  Mtype,Mfun,Margs);
      nfevals = nfevals + iter;         
      nsolves = nsolves + iter;                  
    end
    
    if itfail1 || itfail2                % Unable to evaluate a stage.
      nofailed = false;
      nfailed = nfailed + 1;            
      if Jcurrent                       % never false if Jconstant
        if absh <= hmin
          warning('MATLAB:ode23tb:IntegrationTolNotMet',['Failure at t=%e.  ' ...
                  'Unable to meet integration tolerances without reducing ' ...
                  'the step size below the smallest value allowed (%e) ' ...
                  'at time t.'],t,hmin);

          solver_output = odefinalize(solver_name, sol,...
                                      outputFcn, outputArgs,...
                                      printstats, [nsteps, nfailed, nfevals,...
                                                   npds, ndecomps, nsolves],...
                                      nout, tout, yout,...
                                      haveEventFcn, teout, yeout, ieout,...
                                      {t2data,y2data});
          if nargout > 0
            varargout = solver_output;
          end  
          return;
        else
          abshlast = absh;
          absh = max(0.3 * absh, hmin);
          h = tdir * absh;
          z = (absh / abshlast) * z;    % Rescale z because of new h.
          needNewLU = true;
          done = false;
        end
      else   
        needNewJ = true;
      end
    else
      % Estimate the local truncation error.
      if normcontrol
        normynew = norm(ynew);
        wt = max(wt, normynew);
      else
        wt = max(wt, abs(ynew));
      end
      
      est1 = c1*z + c2*z2 + c3*znew;
      err1 = norm(est1 ./ wt,inf);
      % Modify the estimate to improve it at infinity.  With this a
      % larger step size, but not "too" much larger, is reasonable.
      est2 = U \ (L \ est1);
      nsolves = nsolves + 1;            
      err2 = norm(est2 ./ wt,inf);
      err = max(err2, err1 / 16);  

      if err > rtol                     % Failed step
        nfailed = nfailed + 1;          
        if absh <= hmin
          warning('MATLAB:ode23tb:IntegrationTolNotMet',['Failure at t=%e.  ' ...
                  'Unable to meet integration tolerances without reducing ' ...
                  'the step size below the smallest value allowed (%e) ' ...
                  'at time t.'],t,hmin);
          solver_output = odefinalize(solver_name, sol,...
                                      outputFcn, outputArgs,...
                                      printstats, [nsteps, nfailed, nfevals,...
                                                   npds, ndecomps, nsolves],...
                                      nout, tout, yout,...
                                      haveEventFcn, teout, yeout, ieout,...
                                      {t2data,y2data});
          if nargout > 0
            varargout = solver_output;
          end  
          return;
        end
      
        nofailed = false;
        abshlast = absh;
        absh = max(abshlast * max(0.1, 0.7*(rtol/err)^pow), hmin);
        h = tdir * absh;
        z = (absh / abshlast) * z;
        needNewLU = true;
        done = false;
      else                              % Successful step
        break;
        
      end
    end
  end % while true
  nsteps = nsteps + 1;                  
  
  if haveEventFcn
    [te,ye,ie,valt,stop] = odezero(@ntrp23tb,eventFcn,eventArgs,valt,...
                                   t,y,tnew,ynew,t0,t2,y2);

    if ~isempty(te)
      if output_sol || (nargout > 2)
        teout = [teout, te];
        yeout = [yeout, ye];
        ieout = [ieout, ie];
      end
      if stop               % Stop on a terminal event.               
        % Adjust the interpolation data to [t te(end)].         
        t2_zc = t + alpha*(te(end)-t);
        y2_zc = ntrp23tb(t2_zc,t,y,tnew,ynew,t2,y2);
        t2 = t2_zc;
        y2 = y2_zc;
        tnew = te(end);
        ynew = ye(:,end);
        done = true;
      end
    end
  end    
  
  if output_sol
    nout = nout + 1;
    if nout > length(tout)
      tout = [tout, zeros(1,chunk)];  % requires chunk >= refine
      yout = [yout, zeros(neq,chunk)];
      t2data = [t2data, zeros(1,chunk)];
      y2data = [y2data, zeros(neq,chunk)];
    end
    tout(nout) = tnew;
    yout(:,nout) = ynew;
    t2data(nout) = t2;
    y2data(:,nout) = y2;
  end  

  if output_ty || haveOutputFcn 
    switch outputAt
     case 'SolverSteps'        % computed points, no refinement
      nout_new = 1;
      tout_new = tnew;
      yout_new = ynew;
     case 'RefinedSteps'       % computed points, with refinement
      tref = t + (tnew-t)*S;
      nout_new = refine;
      tout_new = [tref, tnew];
      yout_new = [ntrp23tb(tref,t,y,tnew,ynew,t2,y2), ynew];
     case 'RequestedPoints'    % output only at tspan points
      nout_new =  0;
      tout_new = [];
      yout_new = [];
      while next <= ntspan  
        if tdir * (tnew - tspan(next)) < 0
          if haveEventFcn && stop     % output tstop,ystop
            nout_new = nout_new + 1;
            tout_new = [tout_new, tnew];
            yout_new = [yout_new, ynew];            
          end
          break;
        end  
        nout_new = nout_new + 1;             
        tout_new = [tout_new, tspan(next)];
        if tspan(next) == tnew
          yout_new = [yout_new, ynew];            
        else  
          yout_new = [yout_new, ntrp23tb(tspan(next),t,y,tnew,ynew,t2,y2)];
        end  
        next = next + 1;
      end
    end
    
    if nout_new > 0
      if output_ty
        oldnout = nout;
        nout = nout + nout_new;
        if nout > length(tout)
          tout = [tout, zeros(1,chunk)];  % requires chunk >= refine
          yout = [yout, zeros(neq,chunk)];
        end
        idx = oldnout+1:nout;        
        tout(idx) = tout_new;
        yout(:,idx) = yout_new;
      end
      if haveOutputFcn
        stop = feval(outputFcn,tout_new,yout_new(outputs,:),'',outputArgs{:});
        if stop
          done = true;
        end  
      end     
    end  
  end
  
  if done
    break
  end
    
  % Advance the integration one step.
  t = tnew;
  y = ynew;
  if normcontrol 
    normy = normynew;
  end  
  z = znew; 
  Jcurrent = Jconstant;
  switch Mtype
  case {0,1}
    Mcurrent = true;                    % Constant mass matrix I or M.
  case 2
    % M(t) has already been evaluated at tnew in Mtnew.
    Mt = Mtnew;
    Mcurrent = true;
  case {3,4} % state dependent
    % M(t,y) has not yet been evaluated at the accepted ynew.
    Mcurrent = false;
  end
  
  if nofailed
    q = (err/rtol)^pow;
    ratio = hmax/absh;
    if 0.7 < q*ratio 
      ratio = 0.7/q;
    end
    ratio = min(5, max(0.2, ratio));
    if abs(ratio - 1) > 0.2
      absh = ratio * absh;
      needNewLU = true;
      z = ratio * z;
    end
  end
  
end % while ~done

solver_output = odefinalize(solver_name, sol,...
                            outputFcn, outputArgs,...
                            printstats, [nsteps, nfailed, nfevals,...
                                         npds, ndecomps, nsolves],...
                            nout, tout, yout,...
                            haveEventFcn, teout, yeout, ieout,...
                            {t2data,y2data});
if nargout > 0
  varargout = solver_output;
end  

%------------------------------------------------------------------------------

function [y,z,iter,itfail,rate] = ...
    itsolve(M,t,y,z,d,h,L,U,odeFcn,odeArgs,rtol,wt,rate,Mtype,Mfun,Margs)
% Solve the nonlinear equation M*z = h*f(t,v+d*z) and y = v+d*z. The value v
% is incorporated in the predicted y and is not needed because the y is
% corrected using corrections to z. The argument t is constant during the
% iteration. The function f(t,y) is given by feval(odeFcn,t,y,odeArgs{:}). 
% Similarly, if M is state-dependent, it is given by feval(Mfun,t,y,Margs{:}). 
% L,U is the lu decomposition of the matrix M-d*h*dfdy, where dfdy is an
% approximate Jacobian of f. A simplified Newton (chord) iteration  is used,
% so dfdy and the decomposition are held constant. z is computed to an
% accuracy of kappa*rtol. The rate of convergence of the iteration is
% estimated. If the iteration succeeds, itfail is set false and the estimated
% rate is returned for use on a subsequent step. rate can be used as long as
% neither h nor dfdy changes.   

maxiter = 5;
kappa = 0.5;
itfail = 0;
minnrm = 100 * eps * norm(y ./ wt,inf);

for iter = 1:maxiter
  if Mtype >= 3  % state dependent
    M = feval(Mfun,t,y,Margs{:});
  end
  del = U \ (L \ (h * feval(odeFcn,t,y,odeArgs{:}) - M * z));
  z = z + del;
  y = y + d*del;
  newnrm = norm(del ./ max(wt,abs(y)),inf);
  
  if newnrm <= minnrm
    break;
  elseif iter == 1
    if ~isempty(rate)
      errit = newnrm * rate / (1 - rate) ;
      if errit <= 0.1*kappa*rtol
        break;
      end
    else
      rate = 0;
    end
  elseif newnrm > 0.9*oldnrm
    itfail = 1;
    break;
  else
    rate = max(0.9*rate, newnrm / oldnrm);
    errit = newnrm * rate / (1 - rate);
    if errit <= kappa*rtol
      break;
    elseif iter == maxiter
      itfail = 1;
      break;
    elseif kappa*rtol < errit*rate^(maxiter-iter)
      itfail = 1;
      break;
    end
  end
  
  oldnrm = newnrm;
end

