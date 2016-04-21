function varargout = ode23s(ode,tspan,y0,options,varargin)
%ODE23S  Solve stiff differential equations, low order method.
%   [T,Y] = ODE23S(ODEFUN,TSPAN,Y0) with TSPAN = [T0 TFINAL] integrates the
%   system of differential equations y' = f(t,y) from time T0 to TFINAL with
%   initial conditions Y0. Function ODEFUN(T,Y) must return a column vector
%   corresponding to f(t,y). Each row in the solution array Y corresponds to
%   a time returned in the column vector T. To obtain solutions at specific
%   times T0,T1,...,TFINAL (all increasing or all decreasing), use 
%   TSPAN = [T0 T1 ... TFINAL].     
%   
%   [T,Y] = ODE23S(ODEFUN,TSPAN,Y0,OPTIONS) solves as above with default
%   integration properties replaced by values in OPTIONS, an argument created
%   with the ODESET function. See ODESET for details. Commonly used options
%   are scalar relative error tolerance 'RelTol' (1e-3 by default) and vector
%   of absolute error tolerances 'AbsTol' (all components 1e-6 by default).  
%      
%   [T,Y] = ODE23S(ODEFUN,TSPAN,Y0,OPTIONS,P1,P2...) passes the additional
%   parameters P1,P2,... to the ODE function as ODEFUN(T,Y,P1,P2...), and to
%   all functions specified in OPTIONS. Use OPTIONS = [] as a place holder if
%   no options are set.    
%   
%   The Jacobian matrix df/dy is critical to reliability and efficiency. Use
%   ODESET to set 'Jacobian' to a function FJAC if FJAC(T,Y) returns the
%   Jacobian df/dy or to the matrix df/dy if the Jacobian is constant. If the
%   'Jacobian' option is not set (the default), df/dy is approximated by
%   finite differences. Set 'Vectorized' 'on' if the ODE function is coded so
%   that ODEFUN(T,[Y1 Y2 ...]) returns [ODEFUN(T,Y1) ODEFUN(T,Y2) ...]. If
%   df/dy is a sparse matrix, set 'JPattern' to the sparsity pattern of
%   df/dy, i.e., a sparse matrix S with S(i,j) = 1 if component i of f(t,y)
%   depends on component j of y, and 0 otherwise.    
%   
%   ODE23S can solve problems M*y' = f(t,y) with a constant mass matrix M
%   that is nonsingular. Use ODESET to set the 'Mass' property to the mass
%   matrix. If there are many differential equations, it is important to
%   exploit sparsity: Use a sparse M. Either supply the sparsity pattern of
%   df/dy using the 'JPattern' property or a sparse df/dy using the Jacobian
%   property. ODE15S and ODE23T can solve problems with singular mass
%   matrices.     
%   
%   [T,Y,TE,YE,IE] = ODE23S(ODEFUN,TSPAN,Y0,OPTIONS...) with the 'Events'
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
%   SOL = ODE23S(ODEFUN,[T0 TFINAL],Y0...) returns a structure that can be
%   used with DEVAL to evaluate the solution or its first derivative at 
%   any point between T0 and TFINAL. The steps chosen by ODE23S are returned 
%   in a row vector SOL.x.  For each I, the column SOL.y(:,I) contains 
%   the solution at SOL.x(I). If events were detected, SOL.xe is a row vector 
%   of points at which events occurred. Columns of SOL.ye are the corresponding 
%   solutions, and indices in vector SOL.ie specify which event occurred. 
%
%   Example
%         [t,y]=ode23s(@vdp1000,[0 3000],[2 0]);   
%         plot(t,y(:,1));
%     solves the system y' = vdp1000(t,y), using the default relative error
%     tolerance 1e-3 and the default absolute tolerance of 1e-6 for each
%     component, and plots the first component of the solution.
%
%   See also 
%     other ODE solvers:    ODE15S, ODE23T, ODE23TB, ODE45, ODE23, ODE113
%     options handling:     ODESET, ODEGET
%     output functions:     ODEPLOT, ODEPHAS2, ODEPHAS3, ODEPRINT
%     evaluating solution:  DEVAL
%     ODE examples:         VDPODE, BRUSSODE
%
%   NOTE: 
%     The interpretation of the first input argument of the ODE solvers and
%     some properties available through ODESET have changed in this version
%     of MATLAB. Although we still support the v5 syntax, any new
%     functionality is available only with the new syntax. To see the v5
%     help type in the command line 
%         more on, type ode23s, more off

%   NOTE:
%     This portion describes the v5 syntax of ODE23S.
%
%   [T,Y] = ODE23S('F',TSPAN,Y0) with TSPAN = [T0 TFINAL] integrates the
%   system of differential equations y' = F(t,y) from time T0 to TFINAL with
%   initial conditions Y0.  'F' is a string containing the name of an ODE
%   file.  Function F(T,Y) must return a column vector.  Each row in
%   solution array Y corresponds to a time returned in column vector T.  To
%   obtain solutions at specific times T0, T1, ..., TFINAL (all increasing
%   or all decreasing), use TSPAN = [T0 T1 ... TFINAL].
%   
%   [T,Y] = ODE23S('F',TSPAN,Y0,OPTIONS) solves as above with default
%   integration parameters replaced by values in OPTIONS, an argument
%   created with the ODESET function.  See ODESET for details.  Commonly
%   used options are scalar relative error tolerance 'RelTol' (1e-3 by
%   default) and vector of absolute error tolerances 'AbsTol' (all
%   components 1e-6 by default).
%   
%   [T,Y] = ODE23S('F',TSPAN,Y0,OPTIONS,P1,P2,...) passes the additional
%   parameters P1,P2,... to the ODE file as F(T,Y,FLAG,P1,P2,...) (see
%   ODEFILE).  Use OPTIONS = [] as a place holder if no options are set.
%   
%   It is possible to specify TSPAN, Y0 and OPTIONS in the ODE file (see
%   ODEFILE).  If TSPAN or Y0 is empty, then ODE23S calls the ODE file
%   [TSPAN,Y0,OPTIONS] = F([],[],'init') to obtain any values not supplied
%   in the ODE23S argument list.  Empty arguments at the end of the call
%   list may be omitted, e.g. ODE23S('F').
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
%   ODE23S can solve problems M*y' = F(t,y) with a constant mass matrix M
%   that is nonsingular.  Use ODESET to set Mass to 'M' if the ODE file is
%   coded so that F(T,Y,'mass') returns a constant mass matrix.  The default
%   value of Mass is 'none'. The other solvers of the ODE Suite can solve
%   problems with non-constant mass matrices. ODE15S and ODE23T can solve
%   problems with singular mass matrices. 
%   
%   [T,Y,TE,YE,IE] = ODE23S('F',TSPAN,Y0,OPTIONS) with the Events property
%   in OPTIONS set to 'on', solves as above while also locating zero
%   crossings of an event function defined in the ODE file.  The ODE file
%   must be coded so that F(T,Y,'events') returns appropriate information.
%   See ODEFILE for details.  Output TE is a column vector of times at which
%   events occur, rows of YE are the corresponding solutions, and indices in
%   vector IE specify which event occurred.
%   
%   See also ODEFILE

%   ODE23S is an implementation of a new modified Rosenbrock (2,3) pair with
%   a "free" interpolant.  Local extrapolation is not done.  By default,
%   Jacobians are generated numerically.

%   Details are to be found in The MATLAB ODE Suite, L. F. Shampine and
%   M. W. Reichelt, SIAM Journal on Scientific Computing, 18-1, 1997.

%   Mark W. Reichelt and Lawrence F. Shampine, 3-22-94
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.75.4.4 $  $Date: 2003/10/21 11:55:41 $

solver_name = 'ode23s';

% Check inputs
if nargin < 4
  options = [];
  if nargin < 3
    y0 = [];
    if nargin < 2
      tspan = [];
      if nargin < 1
        error('MATLAB:ode23s:NotEnoughInputs',...
              'Not enough input arguments.  See ODE23s.');
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
FcnHandlesUsed = isa(ode,'function_handle');
output_sol = (FcnHandlesUsed && (nargout==1));      % sol = odeXX(...)
output_ty  = (~output_sol && (nargout > 0));  % [t,y,...] = odeXX(...)
% There might be no output requested...

sol = []; k1data = []; k2data = [];
if output_sol
  sol.solver = solver_name;
  sol.extdata.odefun = ode;
  sol.extdata.options = options;                       
  sol.extdata.varargin = varargin;  
end  
odeFcn  = ode;

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

% Handle the mass matrix. Note: ODE23s only accepts constant Mass Matrices. 
[Mtype, ignore, ignore1, M] =  odemass(FcnHandlesUsed,odeFcn,t0,y0,...
                                          options,varargin);
if Mtype > 0
  if Mtype > 1
    error('MATLAB:ode23s:NonConstantMassMatrix',...
          ['ODE23S cannot solve problems with non-constant mass ' ...
           'matrices.  Use one of the other solvers of the ODE Suite.']);
  else % M
    Msingular = odeget(options,'MassSingular','no','fast');
    if strcmp(Msingular,'maybe')
      warning('MATLAB:ode23s:MassSingularAssumedNo',['ODE23S assumes ' ...
                'MassSingular is ''no''.  See ODE15S or ODE23T.']);
    elseif strcmp(Msingular,'yes')
      error('MATLAB:ode23s:MassSingularYes',...
            ['MassSingular cannot be ''yes'' for this solver.  See ODE15S or ' ...
            'ODE23T.']);
    end    
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

% Initialize method parameters.
pow = 1/3;
d = 1 / (2 + sqrt(2));
e32 = 6 + sqrt(2);

% Compute the initial slope yp.
if Mtype > 0
  [L,U] = lu(M);
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

sqrteps = sqrt(eps);

% hmin is a small number such that t + hmin is clearly different from t in
% the working precision, but with this definition, it is 0 if t = 0.
hmin = 16*eps*abs(t);

if isempty(htry)
  % Compute an initial step size h using yp = y'(t).
  if normcontrol
    wt = max(normy,threshold);
    rh = 1.25 * (norm(yp) / wt) / rtol^pow;  % 1.25 = 1 / 0.8
  else
    wt = max(abs(y),threshold);
    rh = 1.25 * norm(yp ./ wt,inf) / rtol^pow;
  end
  absh = min(hmax, htspan);
  if absh * rh > 1
    absh = 1 / rh;
  end
  absh = max(absh, hmin);
  
  % Compute y''(t) and a better initial step size.
  h = tdir * absh;
  tdel = (t + tdir*min(sqrteps*max(abs(t),abs(t+h)),absh)) - t;
  f1 = feval(odeFcn,t+tdel,y,odeArgs{:});
  nfevals = nfevals + 1;                
  dfdt = (f1 - f0) ./ tdel;
  if normcontrol
    if Mtype > 0
      rh = 1.25*sqrt(0.5 * (norm(U \ (L \ (dfdt + dfdy*yp))) / wt)) / rtol^pow;
    else
      rh = 1.25 * sqrt(0.5 * (norm(dfdt + dfdy*yp) / wt)) / rtol^pow;
    end
  else
    if Mtype > 0
      rh = 1.25*sqrt(0.5*norm((U\(L\(dfdt + dfdy*yp))) ./ wt,inf)) / rtol^pow;
    else
      rh = 1.25 * sqrt(0.5 * norm((dfdt + dfdy*yp) ./ wt,inf)) / rtol^pow;
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

% Initialize the output function.
if haveOutputFcn
  feval(outputFcn,[t tfinal],y(outputs),'init',outputArgs{:});
end

% Allocate memory if we're generating output.
nout = 0;
tout = []; yout = [];
if nargout > 0
  if output_sol
    chunk = min(max(100,50*refine), refine+floor((2^11)/neq));      
    tout = zeros(1,chunk);
    yout = zeros(neq,chunk);
    k1data = zeros(neq,chunk);
    k2data = zeros(neq,chunk);
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

% THE MAIN LOOP

done = false;
while ~done
  
  hmin = 16*eps*abs(t);
  absh = min(hmax, max(hmin, absh));
  h = tdir * absh;
  
  % Stretch the step if within 10% of tfinal-t.
  if 1.1*absh >= abs(tfinal - t)
    h = tfinal - t;
    absh = abs(h);
    done = true;
  end
  
  if ~Jconstant
    if nsteps > 0                       % J is already computed on first step
      if Janalytic
        dfdy = feval(Jac,t,y,Jargs{:});                
      else
        [dfdy,Joptions.fac,nF] = odenumjac(odeFcn, {t,y,odeArgs{:}}, f0, Joptions);    
        nfevals = nfevals + nF;                 
      end  
      npds = npds + 1;                  
    end
  end
  tdel = (t + tdir*min(sqrteps*max(abs(t),abs(t+h)),absh)) - t;
  f1 = feval(odeFcn,t+tdel,y,odeArgs{:});
  dfdt = (f1 - f0) ./ tdel;
  nfevals = nfevals + 1;                
  
  % LOOP FOR ADVANCING ONE STEP.
  nofailed = true;                      % no failed attempts
  while true                            % Evaluate the formula.
    [L,U] = lu(M - (h*d)*dfdy);         % sparse if dfdy is sparse
    k1 = U \ (L \ (f0 + (h*d)*dfdt));
    f1 = feval(odeFcn, t + 0.5*h, y + 0.5*h*k1, odeArgs{:});
    Mk1 = M * k1;
    k2 = (U \ (L \ (f1 - Mk1))) + k1;
    tnew = t + h;
    if done
      tnew = tfinal;   % Hit end point exactly.
    end
    h = tnew - t;      % Purify h.
    
    ynew = y + h*k2;
    f2 = feval(odeFcn, tnew, ynew, odeArgs{:});
    k3 = U \ (L \ (f2 - e32*(M*k2 - f1) - 2*(Mk1 - f0) + (h*d)*dfdt));
    ndecomps = ndecomps + 1;            
    nfevals = nfevals + 2;              
    nsolves = nsolves + 3;              
    
    % Estimate the error.
    if normcontrol
      normynew = norm(ynew);
      err = (absh/6) * (norm(k1-2*k2+k3) / max(max(normy,normynew),threshold));
    else
      err = (absh/6) * ...
          norm((k1-2*k2+k3) ./ max(max(abs(y),abs(ynew)),threshold),inf);
    end
    
    % Accept the solution only if the weighted error is no more than the
    % tolerance rtol.  Estimate an h that will yield an error of rtol on
    % the next step or the next try at taking this step, as the case may be,
    % and use 0.8 of this value to avoid failures.
    if err > rtol                       % Failed step
      nfailed = nfailed + 1;            
      if absh <= hmin
        warning('MATLAB:ode23s:IntegrationTolNotMet',['Failure at t=%e.  ' ...
                  'Unable to meet integration tolerances without reducing ' ...
                  'the step size below the smallest value allowed (%e) ' ...
                  'at time t.'],t,hmin);

        solver_output = odefinalize(solver_name, sol,...
                                    outputFcn, outputArgs,...
                                    printstats, [nsteps, nfailed, nfevals,...
                                                 npds, ndecomps, nsolves],...
                                    nout, tout, yout,...
                                    haveEventFcn, teout, yeout, ieout,...
                                    {k1data,k2data});
        if nargout > 0
          varargout = solver_output;
        end          
        return;
      end
      
      nofailed = false;
      absh = max(hmin, absh * max(0.1, 0.8*(rtol/err)^pow));
      h = tdir * absh;
      done = false;
      
    else                                % Successful step
      break;
      
    end
  end % while true
  nsteps = nsteps + 1;                  
  
  if haveEventFcn
    [te,ye,ie,valt,stop] = odezero(@ntrp23s,eventFcn,eventArgs,valt,...
                                   t,y,tnew,ynew,t0,h,k1,k2);
    if ~isempty(te)
      if output_sol || (nargout > 2)
        teout = [teout, te];
        yeout = [yeout, ye];
        ieout = [ieout, ie];
      end
      if stop          % Stop on a terminal event.               
        % Adjust the interpolation data to [t te(end)].
        
        % Reconstruct the values of k from the interpolating polynomial.
        taux = t + (te(end) - t)*[d,1/2];
        [ignore,K] = ntrp23s(taux,t,y,[],[],h,k1,k2);        
        k1 = K(:,1);
        k2 = K(:,2);
        
        tnew = te(end);
        ynew = ye(:,end);     
        h = tnew - t;        
        done = true;
      end
    end
  end
  
  if output_sol
    nout = nout + 1;
    if nout > length(tout)
      tout = [tout, zeros(1,chunk)];  % requires chunk >= refine
      yout = [yout, zeros(neq,chunk)];
      k1data = [k1data, zeros(neq,chunk)];
      k2data = [k2data, zeros(neq,chunk)];
    end
    tout(nout) = tnew;
    yout(:,nout) = ynew;
    k1data(:,nout) = k1;
    k2data(:,nout) = k2;
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
      yout_new = [ntrp23s(tref,t,y,[],[],h,k1,k2), ynew];
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
          yout_new = [yout_new, ntrp23s(tspan(next),t,y,[],[],h,k1,k2)];
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
    
  % If there were no failures compute a new h.
  if nofailed
    % Note that absh may shrink by 0.8, and that err may be 0.
    temp = 1.25*(err/rtol)^pow;
    if temp > 0.2
      absh = absh / temp;
    else
      absh = 5.0*absh;
    end
  end
  
  % Advance the integration one step.
  t = tnew;
  y = ynew;
  if normcontrol
    normy = normynew;
  end
  f0 = f2;                              % because formula is FSAL
  
end % while ~done

solver_output = odefinalize(solver_name, sol,...
                            outputFcn, outputArgs,...
                            printstats, [nsteps, nfailed, nfevals,...
                                         npds, ndecomps, nsolves],...
                            nout, tout, yout,...
                            haveEventFcn, teout, yeout, ieout,...
                            {k1data,k2data});
if nargout > 0
  varargout = solver_output;
end  
