function varargout = ode23t(ode,tspan,y0,options,varargin)
%ODE23T  Solve moderately stiff ODEs and DAEs, trapezoidal rule.
%   [T,Y] = ODE23T(ODEFUN,TSPAN,Y0) with TSPAN = [T0 TFINAL] integrates the
%   system of differential equations y' = f(t,y) from time T0 to TFINAL with
%   initial conditions Y0. Function ODEFUN(T,Y) must return a column vector
%   corresponding to f(t,y). Each row in the solution array Y corresponds to
%   a time returned in the column vector T. To obtain solutions at specific
%   times T0,T1,...,TFINAL (all increasing or all decreasing), use 
%   TSPAN = [T0 T1 ... TFINAL].     
%   
%   [T,Y] = ODE23T(ODEFUN,TSPAN,Y0,OPTIONS) solves as above with default
%   integration parameters replaced by values in OPTIONS, an argument created
%   with the ODESET function. See ODESET for details. Commonly used options
%   are scalar relative error tolerance 'RelTol' (1e-3 by default) and vector
%   of absolute error tolerances 'AbsTol' (all components 1e-6 by default).  
%   
%   [T,Y] = ODE23T(ODEFUN,TSPAN,Y0,OPTIONS,P1,P2...) passes the additional
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
%   ODE23T can solve problems M(t,y)*y' = f(t,y) with mass matrix M(t,y). Use
%   ODESET to set the 'Mass' property to a function MASS if MASS(T,Y) returns
%   the value of the mass matrix. If the mass matrix is constant, the matrix
%   can be used as the value of the 'Mass' option. Problems with
%   state-dependent mass matrices are more difficult. If the mass matrix does
%   not depend on the state variable Y and the function MASS is to be called
%   with one input argument T, set 'MStateDependence' to 'none'. If the mass
%   matrix depends weakly on Y, set 'MStateDependence' to 'weak' (the
%   default) and otherwise, to 'strong'. In either case the function MASS is
%   to be called with the two arguments (T,Y). If there are many differential
%   equations, it is important to exploit sparsity: Return a sparse
%   M(t,y). Either supply the sparsity pattern of df/dy using the 'JPattern'
%   property or a sparse df/dy using the Jacobian property. For strongly
%   state-dependent M(t,y), set 'MvPattern' to a sparse matrix S with S(i,j)
%   = 1 if for any k, the (i,k) component of M(t,y) depends on component j of
%   y, and 0 otherwise.    
%
%   If the mass matrix is non-singular, the solution of the problem is
%   straightforward. See examples FEM1ODE, FEM2ODE, BATONODE, or
%   BURGERSODE. If M(t0,y0) is singular, the problem is a differential-
%   algebraic equation (DAE). ODE23T solves DAEs of index 1. DAEs have
%   solutions only when y0 is consistent, i.e., there is a yp0 such that
%   M(t0,y0)*yp0 = f(t0,y0). Use ODESET to set 'MassSingular' to 'yes', 'no',
%   or 'maybe'. The default of 'maybe' causes ODE23T to test whether M(t0,y0)
%   is singular. You can provide yp0 as the value of the 'InitialSlope'
%   property. The default is the zero vector. If y0 and yp0 are not
%   consistent, ODE23T treats them as guesses, tries to compute consistent
%   values close to the guesses, and then goes on to solve the problem. See
%   examples HB1DAE or AMP1DAE.    
%
%   [T,Y,TE,YE,IE] = ODE23T(ODEFUN,TSPAN,Y0,OPTIONS...) with the 'Events'
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
%   decreasing. Output TE is a column vector of times at which events occur.
%   Rows of YE are the corresponding solutions, and indices in vector IE
%   specify which event occurred.    
%
%   SOL = ODE23T(ODEFUN,[T0 TFINAL],Y0...) returns a structure that can be
%   used with DEVAL to evaluate the solution or its first derivative at 
%   any point between T0 and TFINAL. The steps chosen by ODE23T are returned 
%   in a row vector SOL.x.  For each I, the column SOL.y(:,I) contains 
%   the solution at SOL.x(I). If events were detected, SOL.xe is a row vector 
%   of points at which events occurred. Columns of SOL.ye are the corresponding 
%   solutions, and indices in vector SOL.ie specify which event occurred. 
%
%   Example
%         [t,y]=ode23t(@vdp1000,[0 3000],[2 0]);   
%         plot(t,y(:,1));
%     solves the system y' = vdp1000(t,y), using the default relative error
%     tolerance 1e-3 and the default absolute tolerance of 1e-6 for each
%     component, and plots the first component of the solution.
%
%   See also 
%     other ODE solvers:    ODE15S, ODE23S, ODE23TB, ODE45, ODE23, ODE113
%     options handling:     ODESET, ODEGET
%     output functions:     ODEPLOT, ODEPHAS2, ODEPHAS3, ODEPRINT
%     evaluating solution:  DEVAL
%     ODE examples:         VDPODE, FEM1ODE, BRUSSODE, HB1DAE
%
%   NOTE: 
%     The interpretation of the first input argument of the ODE solvers and
%     some properties available through ODESET have changed in this version
%     of MATLAB. Although we still support the v5 syntax, any new
%     functionality is available only with the new syntax. To see the v5
%     help type in the command line 
%         more on, type ode23t, more off

%   NOTE:
%     This portion describes the v5 syntax of ODE23T.
%
%   [T,Y] = ODE23T('F',TSPAN,Y0) with TSPAN = [T0 TFINAL] integrates the
%   system of differential equations y' = F(t,y) from time T0 to TFINAL with
%   initial conditions Y0.  'F' is a string containing the name of an ODE
%   file.  Function F(T,Y) must return a column vector.  Each row in
%   solution array Y corresponds to a time returned in column vector T.  To
%   obtain solutions at specific times T0, T1, ..., TFINAL (all increasing
%   or all decreasing), use TSPAN = [T0 T1 ... TFINAL].
%   
%   [T,Y] = ODE23T('F',TSPAN,Y0,OPTIONS) solves as above with default
%   integration parameters replaced by values in OPTIONS, an argument
%   created with the ODESET function.  See ODESET for details.  Commonly
%   used options are scalar relative error tolerance 'RelTol' (1e-3 by
%   default) and vector of absolute error tolerances 'AbsTol' (all
%   components 1e-6 by default).
%   
%   [T,Y] = ODE23T('F',TSPAN,Y0,OPTIONS,P1,P2,...) passes the additional
%   parameters P1,P2,... to the ODE file as F(T,Y,FLAG,P1,P2,...) (see
%   ODEFILE).  Use OPTIONS = [] as a place holder if no options are set.
%   
%   It is possible to specify TSPAN, Y0 and OPTIONS in the ODE file (see
%   ODEFILE).  If TSPAN or Y0 is empty, then ODE23T calls the ODE file
%   [TSPAN,Y0,OPTIONS] = F([],[],'init') to obtain any values not supplied
%   in the ODE23T argument list.  Empty arguments at the end of the call
%   list may be omitted, e.g. ODE23T('F').
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
%   ODE23T can solve problems M(t,y)*y' = F(t,y) with a mass matrix M that
%   is nonsingular.  Use ODESET to set Mass to 'M', 'M(t)', or 'M(t,y)' if
%   the ODE file is coded so that F(T,Y,'mass') returns a constant,
%   time-dependent, or time- and state-dependent mass matrix, respectively.
%   The default value of Mass is 'none'.  
%   
%   If M is singular, M(t)*y' = F(t,y) is a differential-algebraic equation
%   (DAE).  DAEs have solutions only when y0 is consistent, i.e. there is a
%   vector yp0 such that M(t0)*yp0 = f(t0,y0).  ODE23T can solve DAEs of
%   index 1 provided that M is not state dependent and y0 is sufficiently
%   close to being consistent.  You can use ODESET to set MassSingular to
%   'yes', 'no', or 'maybe'.  The default of 'maybe' causes ODE23T to test
%   whether the problem is a DAE. If it is, ODE23T treats y0 as a guess,
%   attempts to compute consistent initial conditions that are close to y0,
%   and goes on to solve the problem. When solving DAEs, it is very
%   advantageous to formulate the problem so that M is diagonal (a
%   semi-explicit DAE). 
%   
%   [T,Y,TE,YE,IE] = ODE23T('F',TSPAN,Y0,OPTIONS) with the Events property
%   in OPTIONS set to 'on', solves as above while also locating zero
%   crossings of an event function defined in the ODE file.  The ODE file
%   must be coded so that F(T,Y,'events') returns appropriate information.
%   See ODEFILE for details.  Output TE is a column vector of times at which
%   events occur, rows of YE are the corresponding solutions, and indices in
%   vector IE specify which event occurred.
%   
%   See also ODEFILE

%   ODE23T is an implementation of the trapezoidal rule.  A "free"
%   interpolant is used. 

%   Mark W. Reichelt, Lawrence F. Shampine, Yanyuan Ma, and Jacek Kierzenka
%   12-18-97
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.30.4.4 $  $Date: 2003/12/26 18:08:53 $

solver_name = 'ode23t';

if nargin < 4
  options = [];
  if nargin < 3
    y0 = [];
    if nargin < 2
      tspan = [];
      if nargin < 1
        error('MATLAB:ode23t:NotEnoughInputs',...
              'Not enough input arguments.  See ODE23t.');
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

sol = []; zdata = []; znewdata = [];  
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
one2neq = (1:neq);

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
[Mtype, Mfun, Margs, Mt, dMoptions] =  odemass(FcnHandlesUsed,odeFcn,t0,y0,...
                                               options,varargin);

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

yp0_OK = false;
DAE = false;
RowScale = [];
if Mtype > 0
  nz = nnz(Mt);
  if nz == 0
    error('MATLAB:ode23t:MassMatrixAllZero',...
          'The mass matrix must have some non-zero entries.')
  end
   
  Msingular = odeget(options,'MassSingular','maybe','fast');
  switch Msingular
    case 'no',     DAE = false;
    case 'yes',    DAE = true;
    case 'maybe',  DAE = (eps*nz*condest(Mt) > 1);       
  end
   
  if DAE
    yp0 = odeget(options,'InitialSlope',[],'fast');
    if isempty(yp0)
      yp0_OK = false;
      yp0 = zeros(neq,1);  
    else
      yp0 = yp0(:);
      if length(yp0) ~= neq
        error('MATLAB:ode23t:YoYPoLengthMismatch',...
              'y0 and yp0 have different lengths.');
      end
      % Test if (y0,yp0) are consistent enough to accept.
      yp0_OK = (norm(Mt*yp0 - f0) <= 1e-3*rtol*max(norm(Mt*yp0),norm(f0)));
    end   
    if ~yp0_OK           % Must compute ICs, so classify them.
      if Mtype >= 3  % state dependent
        ICtype = 3;
      else  % M, M(t)
        % Test for a diagonal mass matrix.
        [r,c] = find(Mt);
        if isequal(r,c)   % diagonal
          ICtype = 1;
        elseif ~issparse(Mt) % not diagonal but full
          ICtype = 2;
        else  % sparse, not diagonal
          ICtype = 3;
        end
      end      
    end
  end
end
Mcurrent = true;
Mtnew = Mt;

% Initialize method parameters.
% The first step is taken at order one with the backward Euler method (BDF1).
pow = 1/2;
gamma = 1;
start = true;

% Adjust the warnings.
warnstat(1) = warning('query','MATLAB:singularMatrix');
warnstat(2) = warning('query','MATLAB:nearlySingularMatrix');
warnoff = warnstat;
warnoff(1).state = 'off';
warnoff(2).state = 'off';

% Get the initial slope yp. For DAEs the default is to compute
% consistent initial conditions.
if DAE && ~yp0_OK
  if ICtype < 3
    [y,yp,f0,dfdy,nFE,nPD,Jfac] = daeic12(odeFcn,odeArgs,t,ICtype,Mt,y,yp0,f0,...
                                          rtol,Jconstant,Jac,Jargs,Joptions);        
  else    
    [y,yp,f0,dfdy,nFE,nPD,Jfac,dMfac] = daeic3(odeFcn,odeArgs,tspan,htry,Mtype,Mt,Mfun,...
                                               Margs,dMoptions,y,yp0,f0,rtol,Jconstant,...
                                               Jac,Jargs,Joptions);       
    if ~isempty(dMoptions)
      dMoptions.fac = dMfac;
    end  
  end  
  if ~isempty(Joptions)
    Joptions.fac = Jfac;
  end  
  nfevals = nfevals + nFE;
  npds = npds + nPD;
  if Mtype >= 3
    Mt = feval(Mfun,t,y,Margs{:});
    Mtnew = Mt;
    Mcurrent = true;
  end
else
  if Mtype == 0 
    yp = f0;
  elseif DAE && yp0_OK
    yp = yp0;
  else
    [L,U] = lu(Mt);
    yp = U \ (L \ f0);
    ndecomps = ndecomps + 1;              
    nsolves = nsolves + 1;                
  end
    
  if Jconstant
    dfdy = Jac;
  elseif Janalytic
    dfdy = feval(Jac,t,y,Jargs{:});     
    npds = npds + 1;                            
  else   % Joptions not empty
    [dfdy,Joptions.fac,nF] = odenumjac(odeFcn, {t,y,odeArgs{:}}, f0, Joptions);  
    nfevals = nfevals + nF;    
    npds = npds + 1;                            
  end     
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
  
  if ~DAE
    % The error of BDF1 is 0.5*h^2*y''(t), so we can determine the optimal h.
    h = tdir * absh;
    tdel = (t + tdir*min(sqrt(eps)*max(abs(t),abs(t+h)),absh)) - t;
    f1 = feval(odeFcn,t+tdel,y,odeArgs{:});
    nfevals = nfevals + 1;                
    dfdt = (f1 - f0) ./ tdel;
    if normcontrol
      if Mtype > 0
        rh = 1.43 * sqrt(0.5 * (norm(U \ (L \ (dfdt + dfdy*yp))) / wt) / rtol);
      else
        rh = 1.43 * sqrt(0.5 * (norm(dfdt + dfdy*yp) / wt) / rtol);
      end
    else
      if Mtype > 0
        rh = 1.43*sqrt(0.5*norm((U \ (L \ (dfdt+dfdy*yp))) ./ wt,inf) / rtol);
      else
        rh = 1.43 * sqrt(0.5 * norm((dfdt + dfdy*yp) ./ wt,inf) / rtol);
      end
    end
    absh = min(hmax, htspan);
    if absh * rh > 1
      absh = 1 / rh;
    end
    absh = max(absh, hmin);
  end
else
  absh = min(hmax, max(hmin, htry));
end
h = tdir * absh;

% Allocate memory if we're generating output.
nout = 0;
tout = []; yout = [];
if nargout > 0
  if output_sol
    chunk = min(max(100,50*refine), refine+floor((2^11)/neq));      
    tout = zeros(1,chunk);
    yout = zeros(neq,chunk);
    zdata = zeros(neq,chunk);
    znewdata = zeros(neq,chunk);
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

z = h * yp;                  % z is the scaled derivative.
if Mtype == 4
  [dMzdy,dMoptions.fac] = odenumjac(@odemxv, {Mfun,t,y,z,Margs{:}}, Mt*z, ...    
                                    dMoptions);      
end          
needNewLU = true;            % Initialize LU.
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
  itfailed = 0;
  while true                            % Evaluate the formula.
    
    if normcontrol
      wt = max(normy,threshold);
    else
      wt = max(abs(y),threshold);
    end    
    
    if needNewJ
      if Janalytic
        dfdy = feval(Jac,t,y,Jargs{:});
      else   % Joptions not empty
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
      if ~Mcurrent
        Mt = feval(Mfun,t,y,Margs{:});
        Mcurrent = true;
        if Mtype == 4
          [dMzdy,dMoptions.fac] = odenumjac(@odemxv, {Mfun,t,y,z,Margs{:}}, Mt*z, ...    
                                            dMoptions);              
        end                  
      end
      Miter = Mt - (gamma*h)*dfdy;
      if Mtype == 4
        Miter = Miter + dMzdy;
      end              
      % Use explicit scaling of the equations when solving DAEs.
      if DAE
        RowScale = 1 ./ max(abs(Miter),[],2);
        Miter = sparse(one2neq,one2neq,RowScale) * Miter;
      end
      [L,U] = lu(Miter);
      ndecomps = ndecomps + 1;          
      rate = [];
      needNewLU = false;
    end
    
    % Predict ynew, znew at tnew.
    tnew = t + h;
    if done
      tnew = tfinal;   % Hit end point exactly.
    end
    h = tnew - t;      % Purify h.
    
    if start                            % Backward Euler (BDF1)
      % Use linear interpolating polynomial.
      znew = z;
      ynew = y + z;
    else                                % Trapezoidal rule (TR)
      % Use quadratic interpolating polynomial.
      a1 = ((tnew - t_2)*(tnew - t_1))/((t - t_2)*(t - t_1));
      a2 = ((tnew - t_2)*(tnew - t))/((t_1 - t_2)*(t_1 - t));
      a3 = ((tnew - t_1)*(tnew - t))/((t_2 - t_1)*(t_2 - t));
      ynew = a1*y + a2*y_1 + a3*y_2;
      znew = 2*(ynew - y) - z;
    end
    
    % Mtnew is required in the RHS function evaluation.
    if Mtype == 2  % state-independent
      if FcnHandlesUsed
        Mtnew = feval(Mfun,tnew,Margs{:}); % mass(t,p1,p2...)
      else                                     
        Mtnew = feval(Mfun,tnew,ynew,Margs{:}); % mass(t,y,'mass',p1,p2...)
      end
    end
    
    [ynew,znew,iter,itfail,rate] = ...
        itsolve(Mtnew,tnew,ynew,znew,gamma,h,L,U,odeFcn,odeArgs,rtol,wt,rate,...
                Mtype,Mfun,Margs,DAE,RowScale,warnstat,warnoff);
    nfevals = nfevals + iter;           
    nsolves = nsolves + iter;           
    
    if itfail
      nofailed = false;
      nfailed = nfailed + 1;            
      itfailed = itfailed + 1;
      if Jcurrent                       % never false if Jconstant
        if absh <= hmin
          warning('MATLAB:ode23t:IntegrationTolNotMet',['Failure at t=%e.  ' ...
                  'Unable to meet integration tolerances without reducing ' ...
                  'the step size below the smallest value allowed (%e) ' ...
                  'at time t.'],t,hmin);            
                        
          solver_output = odefinalize(solver_name, sol,...
                                      outputFcn, outputArgs,...
                                      printstats, [nsteps, nfailed, nfevals,...
                                                   npds, ndecomps, nsolves],...
                                      nout, tout, yout,...
                                      haveEventFcn, teout, yeout, ieout,...
                                      {zdata,znewdata});
          if nargout > 0
            varargout = solver_output;
          end  
          return;    
          
        elseif itfailed == 3 && ~start
          start = true;                 % Need to restart.
          pow = 1/2;                    % Revert to BDF1.
          gamma = 1;
          
          % The local truncation error of BDF1 is (1/2)*y''*h^2. 
          % Approximate by differentiating a quadratic interpolant.
          d1 = y/((t-t_1)*(t-t_2));
          d2 = y_1/((t_1-t)*(t_1-t_2));
          d3 = y_2/((t_2-t)*(t_2-t_1));
          est = d1 + d2 + d3;
          err = norm(est ./ wt,inf)*absh^2;
          q = sqrt(err / rtol);
          ratio = hmax / absh;                 
          if 0.7 < q*ratio
            ratio = 0.7/q;
          end
          abshlast = absh;
          absh = max(ratio * absh, hmin);
          h = tdir * absh;
          z = (absh / abshlast) * z;    % Rescale z because of new h.
          needNewLU = true;
          done = false;  
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
      
      if start
        % The local truncation error is (1/2)*y''*h^2. 
        % Approximate by differencing the scaled derivative.
        err = norm(0.5*(znew - z) ./ wt,inf);
      else
        % The local truncation error is -(1/12)*y'''*h^3. 
        % Approximate by differentiating a cubic interpolant.
        c1 = ynew/((tnew-t_2)*(tnew-t_1)*(tnew-t));
        c2 = y/((t-tnew)*(t-t_2)*(t-t_1));
        c3 = y_1/((t_1-tnew)*(t_1-t)*(t_1-t_2));
        c4 = y_2/((t_2-t)*(t_2-t_1)*(t_2-tnew));
        est = (c1 + c2 + c3 + c4)/2;
        err = norm(est ./ wt,inf)*absh^3;
      end
      
      if err > rtol                     % Failed step
        nfailed = nfailed + 1;          
        if absh <= hmin
          warning('MATLAB:ode23t:IntegrationTolNotMet',['Failure at t=%e.  ' ...
                  'Unable to meet integration tolerances without reducing ' ...
                  'the step size below the smallest value allowed (%e) ' ...
                  'at time t.'],t,hmin);            

          solver_output = odefinalize(solver_name, sol,...
                                      outputFcn, outputArgs,...
                                      printstats, [nsteps, nfailed, nfevals,...
                                                   npds, ndecomps, nsolves],...
                                      nout, tout, yout,...
                                      haveEventFcn, teout, yeout, ieout,...
                                      {zdata,znewdata});
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
    [te,ye,ie,valt,stop] = odezero(@ntrp23t,eventFcn,eventArgs,valt,...
                                   t,y,tnew,ynew,t0,h,z,znew);

    if ~isempty(te)
      if output_sol || (nargout > 2)
        teout = [teout, te];
        yeout = [yeout, ye];
        ieout = [ieout, ie];
      end
      if stop               % Stop on a terminal event.                       
        % Adjust the interpolation data to [t te(end)].         
        tzc = te(end);
        hzc = tzc - t;
        [ignore,ypaux] = ntrp23t(tzc,t,y,[],ynew,h,z,znew);        
        z    = hzc/h * z;  % scaled derivative at t              
        znew = hzc*ypaux;  % scaled derivative at tzc
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
      zdata = [zdata, zeros(neq,chunk)];
      znewdata = [znewdata, zeros(neq,chunk)];
    end
    tout(nout) = tnew;
    yout(:,nout) = ynew;
    zdata(:,nout) = z;
    znewdata(:,nout) = znew;
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
      yout_new = [ntrp23t(tref,t,y,[],ynew,h,z,znew), ynew];
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
          yout_new = [yout_new, ntrp23t(tspan(next),t,y,[],ynew,h,z,znew)];
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
  if start
    % Generate "previously computed" solution by interpolation and
    % put the stored solutions in order, though this is not necessary.
    t_1 = t + 0.5*h;
    y_1 = ntrp23t(t_1,t,y,[],ynew,h,z,znew);
    t_2 = t;
    y_2 = y;
    
    t = tnew;
    y = ynew;
    if normcontrol
      normy = normynew;
    end
    z = znew;
    Jcurrent = Jconstant;
    switch Mtype
    case {0,1}
      Mcurrent = true;                  % Constant mass matrix I or M.
    case 2
      % M(t) has already been evaluated at tnew in Mtnew.
      Mt = Mtnew;
      Mcurrent = true;
    case {3,4} % state dependent
      % M(t,y) has not yet been evaluated at the accepted ynew.
      Mcurrent = false;
    end
    
    % Change from BDF1 to TR.  Doubling the step size is reasonable 
    % with a raise in order and does not change the LU decomposition. 
    start = false;
    pow = 1/3;
    gamma = 0.5;
    absh = 2 * absh;
    z = 2 * z;
  else
    t_2 = t_1;
    y_2 = y_1;
    t_1 = t;
    y_1 = y;
    
    t = tnew;
    y = ynew;
    if normcontrol
      normy = normynew;
    end
    z = znew;
    Jcurrent = Jconstant;
    switch Mtype
    case {0,1}
      Mcurrent = true;                  % Constant mass matrix I or M.
    case 2
      % M(t) has already been evaluated at tnew in Mtnew.
      Mt = Mtnew;
      Mcurrent = true;
    case {3,4} % state dependent
      % M(t,y) has not yet been evaluated at the accepted ynew.
      Mcurrent = false;
    end
    
    if nofailed
      q = (err / rtol)^pow;
      ratio = hmax / absh;                 
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
  end
  
end % while ~done

solver_output = odefinalize(solver_name, sol,...
                            outputFcn, outputArgs,...
                            printstats, [nsteps, nfailed, nfevals,...
                                         npds, ndecomps, nsolves],...
                            nout, tout, yout,...
                            haveEventFcn, teout, yeout, ieout,...
                            {zdata,znewdata});
if nargout > 0
  varargout = solver_output;
end  
     
% --------------------------------------------------------------------------

function [y,z,iter,itfail,rate] = ...
    itsolve(M,t,y,z,gamma,h,L,U,odeFcn,odeArgs,rtol,wt,rate,...
            Mtype,Mfun,Margs,DAE,RowScale,warnstat,warnoff)
% Solve the nonlinear equation M*z = h*f(t,v+gamma*z) and y = v+gamma*z. The
% value v is incorporated in the predicted y and is not needed because the y
% is corrected using corrections to z. The argument t is constant during the
% iteration. The function f(t,y) is given by feval(odeFcn,t,y,odeArgs{:}). 
% Similarly, if M is state-dependent, it is given by feval(Mfun,t,y,Margs{:}). 
% L,U is the lu decomposition of the matrix M-gamma*h*dfdy, where dfdy is an 
% approximate Jacobian of f. A simplified Newton (chord) iteration is used, 
% so dfdy and the decomposition are held constant. z is computed to an accuracy 
% of kappa*rtol. The rate of convergence of the iteration is estimated. If the
% iteration succeeds, itfail is set false and the estimated rate is returned
% for use on a subsequent step. rate can be used as long as neither h nor
% dfdy changes.   

maxiter = 5;
kappa = 0.5;
itfail = 0;
minnrm = 100 * eps * norm(y ./ wt,inf);

for iter = 1:maxiter  
  if Mtype >= 3  % state dependent
    M = feval(Mfun,t,y,Margs{:});
  end  
  rhs = h * feval(odeFcn,t,y,odeArgs{:}) - M * z;
  if DAE                                % Account for row scaling.
    rhs = RowScale .* rhs;
  end
  warning(warnoff);
  del = U \ (L \ rhs);
  warning(warnstat);
  z = z + del;
  y = y + gamma*del;
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

