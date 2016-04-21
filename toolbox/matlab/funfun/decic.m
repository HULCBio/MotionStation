function [y0,yp0,resnrm] = decic(odefun,t0,y0,fixed_y0,yp0,fixed_yp0,...
                                 options,varargin)
%DECIC  Compute consistent initial conditions for ODE15I.
%   [Y0MOD,YP0MOD] = DECIC(ODEFUN,T0,Y0,FIXED_Y0,YP0,FIXED_YP0) uses the input
%   Y0,YP0 as initial guesses for an iteration to find output values such
%   that F(T0,Y0MOD,YP0MOD) = 0. DECIC changes as few components of the guess as
%   possible. You can specify that certain components are to be held fixed by
%   setting FIXED_Y0(i) = 1 if no change is permitted in the guess for Y0(i)
%   and 0 otherwise. An empty array for FIXED_Y0 is interpreted as allowing
%   changes in all entries. FIXED_YP0 is handled similarly. 
%
%   You cannot fix more than length(Y0) components. Depending on the problem,
%   it may not be possible to fix this many. It also may not be possible to
%   fix certain components of Y0 or YP0. It is recommended that you fix no
%   more components than necessary. 
% 
%   [Y0MOD,YP0MOD] = DECIC(ODEFUN,T0,Y0,FIXED_Y0,YP0,FIXED_YP0,OPTIONS)
%   computes as above with default values of integration properties replaced
%   by the values in OPTIONS, a structure created with the ODESET function. 
%
%   [Y0MOD,YP0MOD] = DECIC(ODEFUN,T0,Y0,FIXED_Y0,YP0,FIXED_YP0,OPTIONS,P1,P2...)
%   passes the additional parameters P1,P2,... to the ODE function as
%   ODEFUN(T,Y,YP,P1,P2...), and to all functions specified in OPTIONS. 
%   Use OPTIONS = [] as a place holder if no options are set.    
%
%   [Y0MOD,YP0MOD,RESNRM] = DECIC(ODEFUN,T0,Y0,FIXED_Y0,YP0,FIXED_YP0...)
%   returns the norm of ODEFUN(T0,Y0MOD,YP0MOD) as RESNRM. If the norm 
%   seems unduly large, use OPTIONS to specify smaller RelTol (1e-3 by default).
%
%   See also ODE15I, ODESET, IHB1DAE, IBURGERSODE.

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/05/19 11:15:08 $

neq = length(y0);
if isempty(fixed_y0)
  free_y = 1:neq;
else
  free_y = find(fixed_y0 == 0);
end
if isempty(fixed_yp0)
  free_yp = 1:neq;
else
  free_yp = find(fixed_yp0 == 0);
end
if length(free_y) + length(free_yp) < neq
  error('MATLAB:decic:TooManyFixed',...
        'Cannot specify more than %i components of y0 and yp0.',neq);
end

if nargin < 7
  options = [];
end

rtol = odeget(options,'RelTol',1e-3,'fast');
if (length(rtol) ~= 1) || (rtol <= 0)
  error('MATLAB:decic:OptRelTolNotPosScalar','RelTol must be a positive scalar.');
end
if rtol < 100 * eps 
  rtol = 100 * eps;
  warning('MATLAB:decic:RelTolIncrease', ...
          'RelTol has been increased to %g.',rtol);
end
atol = odeget(options,'AbsTol',1e-6,'fast');
if any(atol <= 0)
  error('MATLAB:decid:OptAbsTolNotPos', 'AbsTol must be positive.');
end

y0 = y0(:);
yp0 = yp0(:);
res = feval(odefun,t0,y0,yp0,varargin{:});

% Initialize the partial derivatives
[Jac,dfdy,dfdyp,Jconstant,dfdy_options,dfdyp_options] = ...
    ode15ipdinit(odefun,t0,y0,yp0,res,options,varargin);

resnrm0 = norm(res);

for counter = 1:10
    
  for chord = 1:3
    [dy,dyp] = sls(res,dfdy,dfdyp,neq,free_y,free_yp);
    
    % If the increments are too big, limit the change
    % in norm to a factor of 2--trust region.
    nrmv = max(norm([y0; yp0]),norm(atol));
    nrmdv = norm([dy; dyp]);
    if nrmdv > 2*nrmv
      factor = 2*nrmv/nrmdv;
      dy = factor*dy;
      dyp = factor*dyp;
      nrmdv = factor*nrmdv;
    end
    y0 = y0 + dy;
    yp0 = yp0 + dyp;
    res = feval(odefun,t0,y0,yp0,varargin{:});
    resnrm = norm(res);
    
    % Test for convergence.  The norm of the residual must
    % be no greater than the initial guess and the norm of
    % the increments must be small in a relative sense.
    if (resnrm <= resnrm0) && (nrmdv <= 1e-3*rtol*nrmv)
      return;
    end   
  end 
  
  [dfdy,dfdyp,dfdy_options,dfdyp_options] = ...
      ode15ipdupdate(Jac,odefun,t0,y0,yp0,res,dfdy,dfdyp,...
                     dfdy_options,dfdyp_options,varargin);
  
end

error('MATLAB:decic:ConvergenceFail', 'Convergence failure in DECIC.')

%---------------------------------------------------------------------------

function [dy,dyp] = sls(res,dfdy,dfdyp,neq,free_y,free_yp)
% Solve the underdetermined system 
%           0 = res + dfdyp*dyp + dfdy*dy
% A solution is obtained with as many components as
% possible of (transformed) dy and dyp set to zero.

dy = zeros(neq,1);
dyp = zeros(neq,1);

fixed = nnz(free_y) + nnz(free_yp);

if isempty(free_y)  % Solve 0 = res + dfdyp*dyp
  [rank,Q,R,E] = qrank(dfdyp);
  rankdef = neq - rank;
  if rankdef > 0
    if rankdef <= fixed
      error('MATLAB:decic:TooManyFixed',...
            'Try freeing %i fixed components.',rankdef)
    else
      error('MATLAB:decic:IndexGTOne', 'Index may be greater than one.')
    end
  end
  d = - Q' * res;
  dyp = E * (R \ d);
  return
end

if isempty(free_yp)  % Solve 0 = res + dfdy*dy
  [rank,Q,R,E] = qrank(dfdy);
  rankdef = neq - rank;
  if rankdef > 0
    if rankdef <= fixed
      error('MATLAB:decic:TooManyFixed',...
            'Try freeing %i fixed components.',rankdef)
    else
      error('MATLAB:decic:IndexGTOne', 'Index may be greater than one.')
    end
  end
  d = - Q' * res;
  dy = E * (R \ d);
  return
end

% Eliminate variables that are not free.
dfdy = dfdy(:,free_y);
dfdyp = dfdyp(:,free_yp);

[rank,Q,R,E] = qrank(dfdyp);
d = - Q' * res;
if rank == neq
  dy(free_y) = 0;
  dyp(free_yp) = E * (R \ d);
else
  S = Q' * dfdy;
  Srank = qrank(S(rank+1:end,:));
  rankdef = neq - (rank + Srank);
  if rankdef > 0
    if rankdef <= fixed
      error('MATLAB:decic:TooManyFixed',...
            'Try freeing %i fixed components.',rankdef);            
    else
      error('MATLAB:decic:IndexGTOne', 'Index may be greater than one.')
    end
  end
  w = S(rank+1:end,:) \ d(rank+1:end); 
  w1p = R(1:rank,1:rank) \ (d(1:rank) - S(1:rank,:) * w);
  dy(free_y) = w;
  nfree_yp = length(free_yp); 
  dyp(free_yp) = E * [w1p; zeros(nfree_yp-rank,1)];
end

%---------------------------------------------------------------------------

function [rank,Q,R,E] = qrank(A)
% QR decomposition with column pivoting and rank determination.
% Have to make A full so that pivoting can be done.
[Q,R,E] = qr(full(A));
tol = max(size(A)')*eps*abs(R(1,1));
rank = nnz(abs(diag(R)) > tol);  % Account for R that are neq x 1.
