function varargout = ode113(ode,tspan,y0,options,varargin)
%ODE113  Solve non-stiff differential equations, variable order method.
%   [T,Y] = ODE113(ODEFUN,TSPAN,Y0) with TSPAN = [T0 TFINAL] integrates the
%   system of differential equations y' = f(t,y) from time T0 to TFINAL with
%   initial conditions Y0. Function ODEFUN(T,Y) must return a column vector
%   corresponding to f(t,y). Each row in the solution array Y corresponds to
%   a time returned in the column vector T. To obtain solutions at specific
%   times T0,T1,...,TFINAL (all increasing or all decreasing), use 
%   TSPAN = [T0 T1 ... TFINAL].     
%   
%   [T,Y] = ODE113(ODEFUN,TSPAN,Y0,OPTIONS) solves as above with default
%   integration properties replaced by values in OPTIONS, an argument created
%   with the ODESET function. See ODESET for details. Commonly used options
%   are scalar relative error tolerance 'RelTol' (1e-3 by default) and vector
%   of absolute error tolerances 'AbsTol' (all components 1e-6 by default).
%   
%   [T,Y] = ODE113(ODEFUN,TSPAN,Y0,OPTIONS,P1,P2...) passes the additional
%   parameters P1,P2,... to the ODE function as ODEFUN(T,Y,P1,P2...), and to
%   all functions specified in OPTIONS. Use OPTIONS = [] as a place holder if
%   no options are set.   
%   
%   ODE113 can solve problems M(t,y)*y' = f(t,y) with mass matrix M that is
%   nonsingular. Use ODESET to set the 'Mass' property to a function MASS if
%   MASS(T,Y) returns the value of the mass matrix. If the mass matrix is
%   constant, the matrix can be used as the value of the 'Mass' option. If
%   the mass matrix does not depend on the state variable Y and the function
%   MASS is to be called with one input argument T, set 'MStateDependence' to
%   'none'. ODE15S and ODE23T can solve problems with singular mass matrices.  
%
%   [T,Y,TE,YE,IE] = ODE113(ODEFUN,TSPAN,Y0,OPTIONS...) with the 'Events'
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
%   SOL = ODE113(ODEFUN,[T0 TFINAL],Y0...) returns a structure that can be
%   used with DEVAL to evaluate the solution or its first derivative at 
%   any point between T0 and TFINAL. The steps chosen by ODE113 are returned 
%   in a row vector SOL.x.  For each I, the column SOL.y(:,I) contains 
%   the solution at SOL.x(I). If events were detected, SOL.xe is a row vector 
%   of points at which events occurred. Columns of SOL.ye are the corresponding 
%   solutions, and indices in vector SOL.ie specify which event occurred. 
%
%   Example    
%         [t,y]=ode113(@vdp1,[0 20],[2 0]);   
%         plot(t,y(:,1));
%     solves the system y' = vdp1(t,y), using the default relative error
%     tolerance 1e-3 and the default absolute tolerance of 1e-6 for each
%     component, and plots the first component of the solution. 
%
%   Class support for inputs TSPAN, Y0, and the result of ODEFUN(T,Y):
%     float: double, single
%
%   See also 
%       other ODE solvers:    ODE45, ODE23, ODE15S, ODE23S, ODE23T, ODE23TB
%       options handling:     ODESET, ODEGET
%       output functions:     ODEPLOT, ODEPHAS2, ODEPHAS3, ODEPRINT
%       evaluating solution:  DEVAL
%       ODE examples:         RIGIDODE, BALLODE, ORBITODE
%
%   NOTE: 
%     The interpretation of the first input argument of the ODE solvers and
%     some properties available through ODESET have changed in this version
%     of MATLAB. Although we still support the v5 syntax, any new
%     functionality is available only with the new syntax. To see the v5
%     help, type in the command line  
%         more on, type ode113, more off

%   NOTE:
%     This portion describes the v5 syntax of ODE113.
%
%   [T,Y] = ODE113('F',TSPAN,Y0) with TSPAN = [T0 TFINAL] integrates the
%   system of differential equations y' = F(t,y) from time T0 to TFINAL with
%   initial conditions Y0.  'F' is a string containing the name of an ODE
%   file.  Function F(T,Y) must return a column vector.  Each row in
%   solution array Y corresponds to a time returned in column vector T.  To
%   obtain solutions at specific times T0, T1, ..., TFINAL (all increasing
%   or all decreasing), use TSPAN = [T0 T1 ... TFINAL].
%   
%   [T,Y] = ODE113('F',TSPAN,Y0,OPTIONS) solves as above with default
%   integration parameters replaced by values in OPTIONS, an argument
%   created with the ODESET function.  See ODESET for details.  Commonly
%   used options are scalar relative error tolerance 'RelTol' (1e-3 by
%   default) and vector of absolute error tolerances 'AbsTol' (all
%   components 1e-6 by default).
%   
%   [T,Y] = ODE113('F',TSPAN,Y0,OPTIONS,P1,P2,...) passes the additional
%   parameters P1,P2,... to the ODE file as F(T,Y,FLAG,P1,P2,...) (see
%   ODEFILE).  Use OPTIONS = [] as a place holder if no options are set.
%   
%   It is possible to specify TSPAN, Y0 and OPTIONS in the ODE file (see
%   ODEFILE).  If TSPAN or Y0 is empty, then ODE113 calls the ODE file
%   [TSPAN,Y0,OPTIONS] = F([],[],'init') to obtain any values not supplied
%   in the ODE113 argument list.  Empty arguments at the end of the call
%   list may be omitted, e.g. ODE113('F').
%   
%   ODE113 can solve problems M(t,y)*y' = F(t,y) with a mass matrix M that
%   is nonsingular.  Use ODESET to set Mass to 'M', 'M(t)', or 'M(t,y)' if
%   the ODE file is coded so that F(T,Y,'mass') returns a constant,
%   time-dependent, or time- and state-dependent mass matrix, respectively.
%   The default value of Mass is 'none'.  See FEM1ODE, FEM2ODE, or BATONODE.
%   ODE15S and ODE23T can solve problems with singular mass matrices.
%   
%   [T,Y,TE,YE,IE] = ODE113('F',TSPAN,Y0,OPTIONS) with the Events property
%   in OPTIONS set to 'on', solves as above while also locating zero
%   crossings of an event function defined in the ODE file.  The ODE file
%   must be coded so that F(T,Y,'events') returns appropriate information.
%   See ODEFILE for details.  Output TE is a column vector of times at which
%   events occur, rows of YE are the corresponding solutions, and indices in
%   vector IE specify which event occurred.
%   
%   See also ODEFILE

%   ODE113 is a fully variable step size, PECE implementation in terms of
%   modified divided differences of the Adams-Bashforth-Moulton family of
%   formulas of orders 1-12.  The natural "free" interpolants are used.
%   Local extrapolation is done.

%   Details are to be found in The MATLAB ODE Suite, L. F. Shampine and
%   M. W. Reichelt, SIAM Journal on Scientific Computing, 18-1, 1997.

%   Mark W. Reichelt and Lawrence F. Shampine, 6-13-94
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.74.4.4 $  $Date: 2004/04/16 22:05:28 $

solver_name = 'ode113';

if nargin < 4
  options = [];
  if nargin < 3
    y0 = [];
    if nargin < 2
      tspan = [];
      if nargin < 1
        error('MATLAB:ode113:NotEnoughInputs',...
              'Not enough input arguments.  See ODE113.');
      end  
    end
  end
end

% Stats
nsteps  = 0;
nfailed = 0;
nfevals = 0; 

% Output
FcnHandlesUsed  = isa(ode,'function_handle');
output_sol = (FcnHandlesUsed && (nargout==1));      % sol = odeXX(...)
output_ty  = (~output_sol && (nargout > 0));  % [t,y,...] = odeXX(...)
% There might be no output requested...

sol = []; klastvec = []; phi3d = []; psi2d = []; 
if output_sol
  sol.solver = solver_name;
  sol.extdata.odefun = ode;
  sol.extdata.options = options;                       
  sol.extdata.varargin = varargin;  
end  
odeFcn = ode;

% Handle solver arguments
[neq, tspan, ntspan, next, t0, tfinal, tdir, y0, f0, odeArgs, ...
 options, threshold, rtol, normcontrol, normy, hmax, htry, htspan, ...
 dataType] =  ...
    odearguments(FcnHandlesUsed, solver_name, odeFcn, tspan, y0,  ...
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
[Mtype, Mfun, Margs, M] =  odemass(FcnHandlesUsed,odeFcn,t0,y0,options,varargin);
if Mtype > 0
  Msingular = odeget(options,'MassSingular','no','fast');
  if strcmp(Msingular,'maybe')
    warning('MATLAB:ode113:MassSingularAssumedNo',['ODE113 assumes ' ...
             'MassSingular is ''no''. See ODE15S or ODE23T.']);
  elseif strcmp(Msingular,'yes')
    error('MATLAB:ode113:MassSingularYes',...
          ['MassSingular cannot be ''yes'' for this solver. See ODE15S or ' ...
           'ODE23T.']);
  end
  if Mtype == 1
    [L,U] = lu(M);
  else
    L = [];
    U = [];
  end  

  % Incorporate the mass matrix into odeFcn and odeArgs.
  [odeFcn,odeArgs] = odemassexplicit(FcnHandlesUsed,Mtype,odeFcn,odeArgs,Mfun,Margs,L,U);
  yp = feval(odeFcn,t0,y0,odeArgs{:});
  nfevals = nfevals + 1;  
else
  yp = f0;  
end 

t = t0;
y = y0;

% Allocate memory if we're generating output.
nout = 0;
tout = []; yout = [];
if nargout > 0
  if output_sol
    chunk = min(max(100,50*refine), refine+floor((2^10)/neq));      
    tout = zeros(1,chunk,dataType);
    yout = zeros(neq,chunk,dataType);
    klastvec = zeros(1,chunk);            % order of the method -- integers
    phi3d = zeros(neq,14,chunk,dataType);
    psi2d = zeros(12,chunk,dataType);      
  else      
    if ntspan > 2                         % output only at tspan points
      tout = zeros(1,ntspan,dataType);
      yout = zeros(neq,ntspan,dataType);
    else                                  % alloc in chunks
      chunk = min(max(100,50*refine), refine+floor((2^13)/neq));
      tout = zeros(1,chunk,dataType);
      yout = zeros(neq,chunk,dataType);
    end
  end  
  nout = 1;
  tout(nout) = t;
  yout(:,nout) = y;  
end

% Initialize method parameters.
maxk = 12;
two = 2 .^ (1:13)';
gstar = [ 0.5000;  0.0833;  0.0417;  0.0264;  ...
          0.0188;  0.0143;  0.0114;  0.00936; ...
          0.00789;  0.00679; 0.00592; 0.00524; 0.00468];

hmin = 16*eps(t);
if isempty(htry)
  % Compute an initial step size h using y'(t).
  absh = min(hmax, htspan);
  if normcontrol
    rh = (norm(yp) / max(norm(y),threshold)) / (0.25 * sqrt(rtol));
  else
    rh = norm(yp ./ max(abs(y),threshold),inf) / (0.25 * sqrt(rtol));
  end
  if absh * rh > 1
    absh = 1 / rh;
  end
  absh = max(absh, hmin);
else
  absh = min(hmax, max(hmin, htry));
end

% Initialize.
k = 1;
K = 1;
phi = zeros(neq,14,dataType);
phi(:,1) = yp;
psi = zeros(12,1,dataType);
alpha = zeros(12,1,dataType);
beta = zeros(12,1,dataType);
sig = zeros(13,1,dataType);
sig(1) = 1;
w = zeros(12,1,dataType);
v = zeros(12,1,dataType);
g = zeros(13,1,dataType);
g(1) = 1;
g(2) = 0.5;

hlast = 0;
klast = 0;
phase1 = true;

% Initialize the output function.
if haveOutputFcn
  feval(outputFcn,[t tfinal],y(outputs),'init',outputArgs{:});  
end

% THE MAIN LOOP

done = false;
while ~done
  
  % By default, hmin is a small number such that t+hmin is only slightly
  % different than t.  It might be 0 if t is 0.
  hmin = 16*eps(t);
  absh = min(hmax, max(hmin, absh));    % couldn't limit absh until new hmin
  h = tdir * absh;
  
  % Stretch the step if within 10% of tfinal-t.
  if 1.1*absh >= abs(tfinal - t)
    h = tfinal - t;
    absh = abs(h);
    done = true;
  end
  
  if haveEventFcn  
    % Cache for adjusting the interplant in case of terminal event.
    phi_start = phi;
    psi_start = psi;    
  end
   
  % LOOP FOR ADVANCING ONE STEP.
  failed = 0;
  if normcontrol
    invwt = 1 / max(norm(y),threshold);
  else
    invwt = 1 ./ max(abs(y),threshold);
  end
  while true

    % Compute coefficients of formulas for this step.  Avoid computing
    % those quantities not changed when step size is not changed.

    % ns is the number of steps taken with h, including the 
    % current one.  When k < ns, no coefficients change
    if h ~= hlast  
      ns = 0;
    end
    if ns <= klast 
      ns = ns + 1;
    end
    if k >= ns
      beta(ns) = 1;
      alpha(ns) = 1 / ns;
      temp1 = h * ns;
      sig(ns+1) = 1;
      for i = ns+1:k
        temp2 = psi(i-1);
        psi(i-1) = temp1;
        temp1 = temp2 + h;
        
        beta(i) = beta(i-1) * psi(i-1) / temp2;
        alpha(i) = h / temp1;
        sig(i+1) = i * alpha(i) * sig(i);
      end
      psi(k) = temp1;

      % Compute coefficients g.
      if ns == 1                        % Initialize v and set w
        v = 1 ./ (K .* (K + 1));
        w = v;
      else
        % If order was raised, update diagonal part of v.
        if k > klast
          v(k) = 1 / (k * (k+1));
          for j = 1:ns-2
            v(k-j) = v(k-j) - alpha(j+1) * v(k-j+1);
          end
        end
        % Update v and set w.
        for iq = 1:k+1-ns
          v(iq) = v(iq) - alpha(ns) * v(iq+1);
          w(iq) = v(iq);
        end
        g(ns+1) = w(1);
      end

      % Compute g in the work vector w.
      for i = ns+2:k+1
        for iq = 1:k+2-i
          w(iq) = w(iq) - alpha(i-1) * w(iq+1);
        end
        g(i) = w(1);
      end
    end   

    % Change phi to phi star.
    i = ns+1:k;
    phi(:,i) = phi(:,i) * diag(beta(i));

    % Predict solution and differences.
    phi(:,k+2) = phi(:,k+1);
    phi(:,k+1) = zeros(neq,1,dataType);
    p = zeros(neq,1,dataType);
    for i = k:-1:1
      p = p + g(i) * phi(:,i);
      phi(:,i) = phi(:,i) + phi(:,i+1);
    end
    
    p = y + h * p;
    tlast = t;
    t = tlast + h;
    if done
      t = tfinal;   % Hit end point exactly.
    end

    yp = feval(odeFcn,t,p,odeArgs{:});
    nfevals = nfevals + 1;

    % Estimate errors at orders k, k-1, k-2.
    phikp1 = yp - phi(:,1);
    if normcontrol
      temp3 = norm(phikp1) * invwt;
      err = absh * (g(k) - g(k+1)) * temp3;
      erk = absh * sig(k+1) * gstar(k) * temp3;
      if k >= 2
        erkm1 = absh * sig(k) * gstar(k-1) * ...
            (norm(phi(:,k)+phikp1) * invwt);
      else
        erkm1 = 0.0;
      end
      if k >= 3
        erkm2 = absh * sig(k-1) * gstar(k-2) * ...
            (norm(phi(:,k-1)+phikp1) * invwt);
      else
        erkm2 = 0.0;
      end
    else
      temp3 = norm(phikp1 .* invwt,inf);
      err = absh * (g(k) - g(k+1)) * temp3;
      erk = absh * sig(k+1) * gstar(k) * temp3;
      if k >= 2
        erkm1 = absh * sig(k) * gstar(k-1) * ...
            norm((phi(:,k)+phikp1) .* invwt,inf);
      else
        erkm1 = 0.0;
      end
      if k >= 3
        erkm2 = absh * sig(k-1) * gstar(k-2) * ...
            norm((phi(:,k-1)+phikp1) .* invwt,inf);
      else
        erkm2 = 0.0;
      end
    end
    
    % Test if order should be lowered
    knew = k;
    if (k == 2) && (erkm1 <= 0.5*erk)
      knew = k - 1;
    end
    if (k > 2) && (max(erkm1,erkm2) <= erk)
      knew = k - 1;
    end
    
    % Test if step successful
    if err > rtol                       % Failed step
      nfailed = nfailed + 1;            
      if absh <= hmin
        warning('MATLAB:ode113:IntegrationTolNotMet',['Failure at t=%e.  ' ...
                'Unable to meet integration tolerances without reducing ' ...
                'the step size below the smallest value allowed (%e) ' ...
                'at time t.'],tlast,hmin);

        solver_output = odefinalize(solver_name, sol,...
                                    outputFcn, outputArgs,...
                                    printstats, [nsteps, nfailed, nfevals],...
                                    nout, tout, yout,...
                                    haveEventFcn, teout, yeout, ieout,...
                                    {klastvec,phi3d,psi2d});
        if nargout > 0
          varargout = solver_output;
        end  
        return;
      end
      
      % Restore t, phi, and psi.
      phase1 = false;
      t = tlast;
      for i = K
        phi(:,i) = (phi(:,i) - phi(:,i+1)) / beta(i);
      end
      for i = 2:k
        psi(i-1) = psi(i) - h;
      end

      failed = failed + 1;
      reduce = 0.5;
      if failed == 3
        knew = 1;
      elseif failed > 3
        reduce = min(0.5, sqrt(0.5*rtol/erk));
      end
      absh = max(reduce * absh, hmin);
      h = tdir * absh;
      k = knew;
      K = 1:k;
      done = false;
      
    else                                % Successful step
      break;
      
    end
  end
  nsteps = nsteps + 1;                  
  
  klast = k;
  hlast = h;

  % Correct and evaluate.
  ylast = y;
  y = p + h * g(k+1) * phikp1;
  yp = feval(odeFcn,t,y,odeArgs{:});
  nfevals = nfevals + 1;                
  
  % Update differences for next step.
  phi(:,k+1) = yp - phi(:,1);
  phi(:,k+2) = phi(:,k+1) - phi(:,k+2);
  for i = K
    phi(:,i) = phi(:,i) + phi(:,k+1);
  end

  if (knew == k-1) || (k == maxk)
    phase1 = false;
  end

  % Select a new order.
  kold = k;
  if phase1                             % Always raise the order in phase1
    k = k + 1;
  elseif knew == k-1                    % Already decided to lower the order
    k = k - 1;
    erk = erkm1;
  elseif k+1 <= ns                      % Estimate error at higher order
    if normcontrol
      erkp1 = absh * gstar(k+1) * (norm(phi(:,k+2)) * invwt);
    else
      erkp1 = absh * gstar(k+1) * norm(phi(:,k+2) .* invwt,inf);
    end
    if k == 1
      if erkp1 < 0.5*erk
        k = k + 1;
        erk = erkp1;
      end
    else
      if erkm1 <= min(erk,erkp1)
        k = k - 1;
        erk = erkm1;
      elseif (k < maxk) && (erkp1 < erk)
        k = k + 1;
        erk = erkp1;
      end
    end
  end
  if k ~= kold
    K = 1:k;
  end
  
  if haveEventFcn
    [te,ye,ie,valt,stop] = odezero(@ntrp113,eventFcn,eventArgs,valt,...
                                   tlast,ylast,t,y,t0,klast,phi,psi); 
    if ~isempty(te)
      if output_sol || (nargout > 2)
        teout = [teout, te];
        yeout = [yeout, ye];
        ieout = [ieout, ie];
      end
      if stop               % Stop on a terminal event.               
        % Adjust the interpolation data to [t te(end)].                                

        % Update the derivative at tzc using the interpolating polynomial.
        tzc = te(end);
        [ignore,ypzc] = ntrp113(tzc,[],[],t,y,klast,phi,psi);

        % Update psi and phi using hzc and ypzc.
        psi = psi_start;
        hzc = tzc - tlast;
        beta(1) = 1;
        temp1 = hzc;
        for i = 2:klast
          temp2 = psi(i-1);
          psi(i-1) = temp1;
          temp1 = temp2 + hzc;          
          beta(i) = beta(i-1) * psi(i-1) / temp2;
        end
        psi(klast) = temp1;

        phi = phi_start;
        phi(:,2:klast) = phi(:,2:klast) * diag(beta(2:klast));  
        phi(:,1:klast+2) = cumsum([ypzc, -phi(:,1:klast+1)],2);        

        t = te(end);
        y = ye(:,end);
        done = true;
      end
    end
  end
   
  if output_sol
    nout = nout + 1;
    if nout > length(tout)
      tout = [tout, zeros(1,chunk,dataType)];  % requires chunk >= refine
      yout = [yout, zeros(neq,chunk,dataType)];
      klastvec = [klastvec, zeros(1,chunk)];   % order of the method -- integers
      phi3d = cat(3,phi3d,zeros(neq,14,chunk,dataType));
      psi2d = [psi2d, zeros(12,chunk,dataType)];
    end
    tout(nout) = t;
    yout(:,nout) = y;
    klastvec(nout) = klast;
    phi3d(:,:,nout) = phi;
    psi2d(:,nout) = psi;
  end  
  
  if output_ty || haveOutputFcn 
    switch outputAt
     case 'SolverSteps'        % computed points, no refinement
      nout_new = 1;
      tout_new = t;
      yout_new = y;
     case 'RefinedSteps'       % computed points, with refinement
      tref = tlast + (t-tlast)*S;
      nout_new = refine;
      tout_new = [tref, t];
      yout_new = [ntrp113(tref,[],[],t,y,klast,phi,psi), y];
     case 'RequestedPoints'    % output only at tspan points
      nout_new =  0;
      tout_new = [];
      yout_new = [];
      while next <= ntspan  
        if tdir * (t - tspan(next)) < 0
          if haveEventFcn && stop     % output tstop,ystop
            nout_new = nout_new + 1;
            tout_new = [tout_new, t];
            yout_new = [yout_new, y];            
          end
          break;
        end
        nout_new = nout_new + 1;
        tout_new = [tout_new, tspan(next)];
        if tspan(next) == t
          yout_new = [yout_new, y];
        else
          yout_new = [yout_new, ntrp113(tspan(next),[],[],t,y,klast,phi,psi)];
        end                    
        next = next + 1;
      end
    end
    
    if nout_new > 0
      if output_ty
        oldnout = nout;
        nout = nout + nout_new;
        if nout > length(tout)
          tout = [tout, zeros(1,chunk,dataType)];  % requires chunk >= refine
          yout = [yout, zeros(neq,chunk,dataType)];
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
  
  % Select a new step size.
  if phase1
    absh = 2 * absh;
  elseif 0.5*rtol >= erk*two(k+1)
    absh = 2 * absh;      
  elseif 0.5*rtol < erk
    reduce = (0.5 * rtol / erk)^(1 / (k+1));
    absh = absh * max(0.5, min(0.9, reduce));
  end
  
end

solver_output = odefinalize(solver_name, sol,...
                            outputFcn, outputArgs,...
                            printstats, [nsteps, nfailed, nfevals],...
                            nout, tout, yout,...
                            haveEventFcn, teout, yeout, ieout,...
                            {klastvec,phi3d,psi2d});
if nargout > 0
  varargout = solver_output;
end  
