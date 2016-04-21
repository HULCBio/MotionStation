function varargout = ode15i(ode,tspan,y0,yp0,options,varargin)
%ODE15I  Solve fully implicit differential equations, variable order method.
%   [T,Y] = ODE15I(ODEFUN,TSPAN,Y0,YP0) with TSPAN = [T0 TFINAL] integrates 
%   the system of differential equations f(t,y,y') = 0 from time T0 to TFINAL 
%   with initial conditions Y0,YP0. Function ODE15I solves ODEs and DAEs of 
%   index 1.  The initial conditions must be "consistent", meaning that 
%   f(T0,Y0,YP0) = 0. Function DECIC computes consistent initial conditions 
%   close to guessed values.  Function ODEFUN(T,Y,YP) must return a column 
%   vector corresponding to f(t,y,y'). Each row in the solution array Y 
%   corresponds to a time returned in the column vector T. To obtain solutions
%   at specific times T0,T1,...,TFINAL (all increasing or all decreasing), use 
%   TSPAN = [T0 T1  ... TFINAL].     
%   
%   [T,Y] = ODE15I(ODEFUN,TSPAN,Y0,YP0,OPTIONS) solves as above with default
%   integration properties replaced by values in OPTIONS, an argument created
%   with the ODESET function. See ODESET for details. Commonly used options
%   are scalar relative error tolerance 'RelTol' (1e-3 by default) and vector
%   of absolute error tolerances 'AbsTol' (all components 1e-6 by default).  
%   
%   [T,Y] = ODE15I(ODEFUN,TSPAN,Y0,YP0,OPTIONS,P1,P2...) passes the additional
%   parameters P1,P2,... to the ODE function as ODEFUN(T,Y,P1,P2...), and to
%   all functions specified in OPTIONS. Use OPTIONS = [] as a place holder if
%   no options are set.    
%   
%   The Jacobian matrices df/dy and df/dy' are critical to reliability and 
%   efficiency. Use ODESET to set 'Jacobian' to a function FJAC if FJAC(T,Y,YP) 
%   returns [DFDY, DFDYP]. If DFDY = [], dfdy is approximated by finite 
%   differences and similarly for DFDYP.  If the 'Jacobian' option is not set 
%   (the default), both matrices are approximated by finite differences. 
%   Set 'Vectorized' {'on','off'} if the ODE function is coded so
%   that ODEFUN(T,[Y1 Y2 ...],YP) returns [ODEFUN(T,Y1,YP) ODEFUN(T,Y2,YP) ...]. 
%   Set 'Vectorized' {'off','on'} if the ODE function is coded so that
%   ODEFUN(T,Y,[YP1 YP2 ...]) returns [ODEFUN(T,Y,YP1) ODEFUN(T,Y,YP2) ...].    
%   If df/dy or df/dy' is a sparse matrix, set 'JPattern' to the sparsity
%   patterns, {SPDY,SPDYP}. A sparsity pattern of df/dy is a sparse
%   matrix SPDY with SPDY(i,j) = 1 if component i of f(t,y,yp)
%   depends on component j of y, and 0 otherwise. Use SPDY = [] to
%   indicate that df/dy is a full matrix. Similarly for df/dy' and
%   SPDYP. The default value of 'JPattern' is {[],[]}.
%
%   [T,Y,TE,YE,IE] = ODE15I(ODEFUN,TSPAN,Y0,YP0,OPTIONS...) with the 'Events'
%   property in OPTIONS set to a function EVENTS, solves as above while also
%   finding where functions of (T,Y,YP), called event functions, are zero. For
%   each function you specify whether the integration is to terminate at a
%   zero and whether the direction of the zero crossing matters. These are
%   the three vectors returned by EVENTS: [VALUE,ISTERMINAL,DIRECTION] =
%   EVENTS(T,Y,YP). For the I-th event function: VALUE(I) is the value of the
%   function, ISTERMINAL(I)=1 if the integration is to terminate at a zero of
%   this event function and 0 otherwise. DIRECTION(I)=0 if all zeros are to
%   be computed (the default), +1 if only zeros where the event function is
%   increasing, and -1 if only zeros where the event function is
%   decreasing. Output TE is a column vector of times at which events occur.
%   Rows of YE are the corresponding solutions, and indices in vector IE
%   specify which event occurred.    
%   
%   SOL = ODE15I(ODEFUN,[T0 TFINAL],Y0,YP0,...) returns a structure that
%   can be  used with DEVAL to evaluate the solution or its first derivative 
%   at any point between T0 and TFINAL. The steps chosen by ODE15I are returned 
%   in a row vector SOL.x.  For each I, the column SOL.y(:,I) contains 
%   the solution at SOL.x(I). If events were detected, SOL.xe is a row vector 
%   of points at which events occurred. Columns of SOL.ye are the corresponding 
%   solutions, and indices in vector SOL.ie specify which event occurred. 
%
%   Example
%         t0 = 1;
%         y0 = sqrt(3/2);
%         yp0 = 0;
%         [y0,yp0] = decic(@weissinger,t0,y0,1,yp0,0);
%     uses a helper function DECIC to hold fixed the initial value for y(t0)
%     and compute a consistent intial value for y'(t0) for the Weissinger
%     implicit ODE. The ODE is solved using ODE15I and the numerical solution
%     is plotted against the analytical solution    
%         [t,y] = ode15i(@weissinger,[1 10],y0,yp0);
%         ytrue = sqrt(t.^2 + 0.5);
%         plot(t,y,t,ytrue,'o');
%
%   See also 
%     options handling:     ODESET, ODEGET
%     output functions:     ODEPLOT, ODEPHAS2, ODEPHAS3, ODEPRINT
%     evaluating solution:  DEVAL
%     ODE examples:         IHB1DAE, IBURGERSODE

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2003/12/26 18:08:51 $

solver_name = 'ode15i';

% Check inputs
if nargin < 5
  options = [];
  if nargin < 4
    error('MATLAB:ode15i:NotEnoughInputs',...
          'Not enough input arguments.  See ODE15I.');
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
FcnHandlesUsed  = true;   % No MATLAB v. 5 legacy. 
output_sol = (FcnHandlesUsed && (nargout==1));      % sol = odeXX(...)
output_ty  = (~output_sol && (nargout > 0));  % [t,y,...] = odeXX(...)
% There might be no output requested...

sol = []; kvec = [];  
if output_sol
  sol.solver = solver_name;
  sol.extdata.odefun = ode;
  sol.extdata.options = options;                       
  sol.extdata.varargin = varargin;  
end  
odeFcn  = ode;
odeArgs = varargin;   

% Handle solver arguments -- pass yp0 as first extra parameter.
[neq, tspan, ntspan, next, t0, tfinal, tdir, y0, f0, ignore, ...
 options, threshold, rtol, normcontrol, normy, hmax, htry, htspan]  ...
    = odearguments(FcnHandlesUsed, solver_name, odeFcn, tspan, y0,  ...
                   options, [{yp0(:)} varargin]);
nfevals = nfevals + 1;

% Handle the output
if nargout > 0
  outputFcn = odeget(options,'OutputFcn',[],'fast');
else
  outputFcn = odeget(options,'OutputFcn',@odeplot,'fast');
end
outputArgs  = {};      
if isempty(outputFcn)
  haveOutputFcn = false;
else
  haveOutputFcn = true;
  outputs = odeget(options,'OutputSel',1:neq,'fast');
  outputArgs = varargin;
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

t = t0;
y = y0;
yp = yp0;  % Assumes consistent initial slope is supplied.

% Initialize the partial derivatives
[Jac,dfdy,dfdyp,Jconstant,dfdy_options,dfdyp_options,nfcn] = ...
    ode15ipdinit(odeFcn,t0,y0,yp0,f0,options,varargin);

npds = npds + 1;  
nfevals = nfevals + nfcn;

PDscurrent = true;    

maxk = odeget(options,'MaxOrder',5,'fast');

% Initialize method parameters for BDFs in Lagrangian form
% and constant step size.  Column k corresponds to the formula 
% of order k.  lcf holds the leading coefficient, cf holds 
% the rest.
lcf = [  1  3/2 11/6  25/12 137/60 ];  
cf =  [ -1  -2   -3    -4     -5
         0  1/2  3/2    3      5
         0   0  -1/3  -4/3  -10/3
         0   0    0    1/4    5/4
         0   0    0     0    -1/5 ];
     
% derM(:,k) contains coefficients for calculating scaled
% derivative of order k using equally spaced mesh.       
derM = [  1  1  1  1   1   1
         -1 -2 -3 -4  -5  -6
          0  1  3  6  10  15
          0  0 -1 -4 -10 -20
          0  0  0  1   5  15
          0  0  0  0  -1  -6
          0  0  0  0   0   1 ];

maxit = 4;

% Adjust the warnings.
warnstat(1) = warning('query','MATLAB:singularMatrix');
warnstat(2) = warning('query','MATLAB:nearlySingularMatrix');
warnoff = warnstat;
warnoff(1).state = 'off';
warnoff(2).state = 'off';

% hmin is a small number such that t + hmin is clearly different from t in
% the working precision, but with this definition, it is 0 if t = 0.
hmin = 16*eps*abs(t);

if isempty(htry)
  % Compute an initial step size h using yp = y'(t0).
  wt = max(abs(y),threshold);
  rh = 1.25 * norm(yp ./ wt,inf) / sqrt(rtol);
  absh = min(hmax, htspan);
  if absh * rh > 1
    absh = 1 / rh;
  end
  absh = max(absh, hmin); 
else
  absh = min(hmax, max(hmin, htry));
end
h = tdir * absh;

% Initialize.  Set dummy value for klast to force the
% formation of iteration matrix.
k = 1;               
klast = 0;
abshlast = absh;
raised_order = false;

% For j = 1:6
%   t_{n+1-j} are stored in mesh(j)
%   y_{n+1-j} are stored in meshsol(:,j)
mesh = zeros(1,maxk+2);
mesh(1) = t0;
meshsol = zeros(neq,maxk+2);
meshsol(:,1) = y0;
% Using the initial slope, create fictious solution at t - h for 
% starting the integration.
mesh(2) = t0 - h;
meshsol(:,2) = y0 - h*yp0;
nconh = 1;

% Allocate memory if we're generating output.
nout = 0;
tout = []; yout = [];
if nargout > 0
  if output_sol
    chunk = min(max(100,50*refine), refine+floor((2^11)/neq));      
    tout = zeros(1,chunk);
    yout = zeros(neq,chunk);
    kvec = zeros(1,chunk);
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

done = false;
while ~done
  
  hmin = 16*eps*abs(t);
  absh = min(hmax, max(hmin, absh));
  
  % Stretch the step if within 10% of tfinal-t.
  if 1.1*absh >= abs(tfinal - t)
    h = tfinal - t;
    absh = abs(h);
    done = true;
  end 

  % LOOP FOR ADVANCING ONE STEP.
  nfails = 0;
  while true                            % Evaluate the formula.
     
    gotynew = false;                    % is ynew evaluated yet?
    invwt = 1 ./ max(abs(y),threshold);
    while ~gotynew
      
      h = tdir * absh;
      tnew = t + h;
      if done
        tnew = tfinal;   % Hit end point exactly.
      end
      h = tnew - t;      % Purify h. 
      
      if (absh ~= abshlast) || (k ~= klast)
        if absh ~= abshlast
          nconh = 0;
        end
        [L,U] = lu(dfdy + (lcf(k)/h)*dfdyp);
        ndecomps = ndecomps + 1;            
        havrate = false;
        rate = 1;   % Dummy value for test.
      end
      
      % Predict the solution and its derivative at tnew.
      c = weights(mesh(1:k+1),tnew,1);
      ynew  = meshsol(:,1:k+1) * c(:,1);
      ypnew = meshsol(:,1:k+1) * c(:,2);
      ypred = ynew;
      minnrm = 100*eps*norm(ypred .* invwt,inf);

      % Compute local truncation error constant.
      erconst = - 1/(k+1);
      for j = 2:k
        erconst = erconst - ...
                cf(j,k)*prod(((t - (j-1)*h) - mesh(1:k+1)) ./ (h * (1:k+1)));
      end
      erconst = abs(erconst);        

      % Iterate with simplified Newton method.
      tooslow = false;
      for iter = 1:maxit
        rhs = - feval(odeFcn,tnew,ynew,ypnew,odeArgs{:});
        warning(warnoff);
        del = U \ (L \ rhs);
        warning(warnstat);
        newnrm = norm(del .* invwt,inf);
        ynew  = ynew + del;
        ypnew = ypnew + (lcf(k)/h) * del;
        
        if iter == 1
          if newnrm <= minnrm
            gotynew = true;
            break;
          end
          savnrm = newnrm;
        else
          rate = (newnrm/savnrm)^(1/(iter-1));
          havrate = true;
          if rate > 0.9
            tooslow = true;
            break;
          end
        end
        if havrate && ((newnrm * rate/(1 - rate)) <= 0.33*rtol)
          gotynew = true;
          break;
        elseif iter == maxit
          tooslow = true;
          break;
        end
        
      end                               % end of Newton loop
      nfevals = nfevals + iter;         
      nsolves = nsolves + iter;  

      if tooslow
        nfailed = nfailed + 1;
        abshlast = absh;
        klast = k;
        % Speed up the iteration by forming new linearization or reducing h.
        if ~PDscurrent   % always current if Jconstant                  
          if isempty(dfdy_options) && isempty(dfdyp_options)
            f = [];   % No numerical approximations formed
          else 
            f = feval(odeFcn,t,y,yp,odeArgs{:});
            nfevals = nfevals + 1;
          end
          [dfdy,dfdyp,dfdy_options,dfdyp_options,NF] = ...
              ode15ipdupdate(Jac,odeFcn,t,y,yp,f,dfdy,dfdyp,dfdy_options,dfdyp_options,odeArgs);
          
          npds = npds + 1;            
          nfevals = nfevals + NF;
          PDscurrent = true;
          
          % Set a dummy value of klast to force formation of iteration matrix.
          klast = 0;
          
        elseif absh <= hmin
          warning('MATLAB:ode15i:IntegrationTolNotMet',['Failure at t=%e.  ' ...
                    'Unable to meet integration tolerances without reducing '...
                    'the step size below the smallest value allowed (%e) '...
                    'at time t.'],t,hmin);
          solver_output = odefinalize(solver_name, sol,...
                                      outputFcn, outputArgs,...
                                      printstats, [nsteps, nfailed, nfevals,...
                                                   npds, ndecomps, nsolves],...
                                      nout, tout, yout,...
                                      haveEventFcn, teout, yeout, ieout,...
                                      {kvec,yp});
          if nargout > 0
            varargout = solver_output;
          end  
          return;
          
        else
          absh = 0.25 * absh;
          done = false; 
        end
      end   
    end     % end of while loop for getting ynew
    
    % Using the tentative solution, approximate scaled derivative 
    % used to estimate the error of the step.
    sderkp1 = norm((ynew - ypred) .* invwt,inf) * ...
              abs(prod((absh * (1:k+1)) ./ (tnew - mesh(1:k+1))));
    erropt = sderkp1 / (k+1);    % Error assuming constant step size.    
    err = sderkp1 * erconst;     % Error accounting for irregular mesh.

    % Approximate directly derivatives needed to consider lowering the
    % order.  Multiply by a power of h to get scaled derivative.
    kopt = k;
    if k > 1
      if nconh >= k
        sderk = norm(([ynew,meshsol(:,1:k)] * derM(1:k+1,k)) .* invwt,inf);
      else
        c = weights([tnew,mesh(1:k)],tnew,k);
        sderk = norm(([ynew,meshsol(:,1:k)] * c(:,k+1)) .* invwt,inf) * absh^k;
      end
      if k == 2
        if sderk <= 0.5*sderkp1;
          kopt = k - 1;
          erropt = sderk / k;
        end
      else
        if nconh >= k-1
          sderkm1 = norm(([ynew,meshsol(:,1:k-1)] * derM(1:k,k-1)) .* invwt,inf);
        else
          c = weights([tnew mesh(1:k-1)],tnew,k-1);
          sderkm1 = norm(([ynew,meshsol(:,1:k-1)] * c(:,k)) .* invwt,inf) * absh^(k-1);
        end
        if max(sderkm1,sderk) <= sderkp1
          kopt = k - 1;
          erropt = sderk / k;
        end
      end
    end

    if err > rtol                       % Failed step
      nfailed = nfailed + 1;
      if absh <= hmin
        warning('MATLAB:ode15i:IntegrationTolNotMet',['Failure at t=%e.  ' ...
                    'Unable to meet integration tolerances without reducing '...
                    'the step size below the smallest value allowed (%e) '...
                    'at time t.'],t,hmin);
        solver_output = odefinalize(solver_name, sol,...
                                    outputFcn, outputArgs,...
                                    printstats, [nsteps, nfailed, nfevals,...
                                                 npds, ndecomps, nsolves],...
                                    nout, tout, yout,...
                                    haveEventFcn, teout, yeout, ieout,...
                                    {kvec,yp});
        if nargout > 0
          varargout = solver_output;
        end  
        return;
      end
            
      abshlast = absh;
      klast = k;
      nfails = nfails + 1;
      switch nfails
      case 1
        absh = absh * min(0.9,max(0.25, 0.9*(0.5*rtol/erropt)^(1/(kopt+1)))); 
      case 2
        absh = absh * 0.25;
      otherwise
        kopt = 1;
        absh = absh * 0.25;
      end
      absh = max(absh,hmin);
      if absh < abshlast
        done = false;
      end
      k = kopt;      
      
    else                                % Successful step
      break;
      
    end
  end % while true
  nsteps = nsteps + 1;   
    
  if haveEventFcn
    [te,ye,ie,valt,stop] = odezero(@ntrp15i,eventFcn,eventArgs,valt,...
                                   t,y,tnew,ynew,t0,mesh(1:k),meshsol(:,1:k));
    if ~isempty(te)
      if output_sol || (nargout > 2)
        teout = [teout, te];
        yeout = [yeout, ye];
        ieout = [ieout, ie];
      end
      if stop               % Stop on a terminal event.               
        % Adjust the interpolation data to [t te(end)].                 
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
      kvec = [kvec, zeros(1,chunk)];
    end
    tout(nout) = tnew;
    yout(:,nout) = ynew;
    kvec(nout) = k;
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
      yout_new = [ntrp15i(tref,[],[],tnew,ynew,mesh(1:k),meshsol(:,1:k)), ynew];
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
          yout_new = [yout_new, ntrp15i(tspan(next),[],[],tnew,ynew,...
                                        mesh(1:k),meshsol(:,1:k))];
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
  yp = ypnew;
  mesh = [t mesh(1:end-1)];
  meshsol = [y meshsol(:,1:end-1)]; 
  PDscurrent = Jconstant;
  
  klast = k;
  abshlast = absh;
  nconh = min(nconh+1,maxk+2);

  % Estimate the scaled derivative of order k+2 if 
  %  *  at constant step size, 
  %  *  have not already decided to reduce the order, 
  %  *  not already at the maximum order, and
  %  *  did not raise order on last step. 
  if (nconh >= k + 2) && ~(kopt < k) && ~(k == maxk) && ~raised_order
    sderkp2 = norm((meshsol(:,1:k+3) * derM(1:k+3,k+2)) .* invwt,inf);
    if (k > 1) && (sderk <= min(sderkp1,sderkp2))
      kopt = k - 1;
      erropt = sderk / k;
    elseif ((k == 1) && (sderkp2 < 0.5*sderkp1)) || ...
           ((k > 1) && (sderkp2 < sderkp1))
      kopt = k + 1;
      erropt = sderkp2 / (k + 2);
    end      
  end
  temp = (erropt/(0.5*rtol))^(1/(kopt+1));  % hopt = absh/temp
  if temp <= 1/2 
    absh = absh * 2;
  elseif temp > 1
    absh = absh * max(0.5,min(0.9,1/temp));
  end
  raised_order = kopt > k;
  k = kopt;
    
end % while ~done

solver_output = odefinalize(solver_name, sol,...
                            outputFcn, outputArgs,...
                            printstats, [nsteps, nfailed, nfevals,...
                                         npds, ndecomps, nsolves],...
                            nout, tout, yout,...
                            haveEventFcn, teout, yeout, ieout,...
                            {kvec,yp});
if nargout > 0
  varargout = solver_output;
end  

% -----------------------------
function c = weights(x,xi,maxder)
% Compute Lagrangian interpolation coeffients c for the value at xi 
% of a polynomial interpolating at distinct nodes x(1),...,x(N) and
% derivatives of the polynomial of orders 0,...,maxder.  c(j,d+1) 
% is the coefficient of the function value corresponding to x(j) when
% computing the derivative of order d.  Note that maxder <= N-1.
%
% This program is based on the Fortran code WEIGHTS1 of B. Fornberg, 
% A Practical Guide to to Pseudospectral Methods, Cambridge University
% Press, 1995.

n = length(x) - 1;
c = zeros(n+1,maxder+1);
c(1,1) = 1;
tmp1 = 1;
tmp4 = x(1) - xi;
for i = 1:n
    mn = min(i,maxder);
    tmp2 = 1;
    tmp5 = tmp4;
    tmp4 = x(i+1) - xi;
    for j = 0:i-1
        tmp3 = x(i+1) - x(j+1);
        tmp2 = tmp2*tmp3;
        if j == i-1
          for k = mn:-1:1
            c(i+1,k+1) = tmp1*(k*c(i,k) - tmp5*c(i,k+1))/tmp2;
          end
          c(i+1,1) = - tmp1*tmp5*c(i,1)/tmp2;
        end
        for k = mn:-1:1
          c(j+1,k+1) = (tmp4*c(j+1,k+1) - k*c(j+1,k))/tmp3;
        end
        c(j+1,1) = tmp4*c(j+1,1)/tmp3;
    end
    tmp1 = tmp2;
end
