function [y,yp,f,DfDy,nFE,nPD,Jfac,dMfac] = ...
    daeic3(fun,args,tspan,hinit,Mtype,M0,Mfun,Margs,dMoptions,...
           y0,yp0,f0,reltol,Jconstant,Jac,Jargs,Joptions)
%DAEIC3  Helper function to compute initial conditions of type 3.
%   DAEIC3 attempts to find a set of consistent initial conditions for problems
%   of the form M(t,y)*y' = f(t,y).  For ICtype = 3, either the mass matrix 
%   depends on y or it is sparse and not diagonal.  The initial point t0 is 
%   extracted from the array tspan specifying the interval of integration and 
%   the output points.  y0 is a guess for y(t0), yp0 is a guess for y'(t0), 
%   f0 = f(t0,y0), M0 = M(t0,y0), and fun is a function for evaluating f(t,y)
%   and M(t,y). The output y and yp are such that M(t0,y)*yp = f(t0,y) is
%   satisfied much more accurately than the relative  error tolerance RelTol.  
%   Good guesses y0 and yp0 may be necessary for state-dependent mass 
%   matrices, Mtype = 3 or 4, especially for strongly state-dependent matrices, 
%   Mtype = 4.  Generally, but not always, the y and yp returned are close to y0 
%   and yp0.  f is f(t0,y). DfDy is the Jacobian of f evaluated at (t0,y).  If the
%   Jacobian was computed numerically, the quantities fac and g are returned for 
%   subsequent use, and otherwise they are returned as empty arrays.  The number of 
%   evaluations of odefile is provided by nFE and the number of evaluations of the 
%   Jacobian is provided by nPD.
%   
%   See also DAEIC12, ODE15S, ODE23T.

%   Jacek Kierzenka, Lawrence F. Shampine, and Mark W. Reichelt, 12-18-97
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.14.4.3 $

Jfac = [];
dMfac = [];
nFE = 0;
nPD = 0;

neq = length(y0);

Janalytic = isempty(Joptions);

t0 = tspan(1);
t1 = tspan(2);

% A relatively large initial value of h is chosen because a value
% that is "too" small emphasizes M0 in the iteration matrix, so
% makes the matrix ill-conditioned.  This can be handled with row
% scaling when the problem is in semi-explicit form, but not in
% general.
htry = 1e-4*abs(t0);    
if htry == 0
  htry = 1e-4*abs(t1);
end
if ~isempty(hinit)
  htry = min(abs(hinit),htry);  % do not go above hinit.
end
absh = min(htry, abs(t1 - t0));

% When t0 = 0 and t1 is "big", the initial h may be much too big.
% Balancing the sizes of the terms in the iteration matrix is used
% to select a more suitable value then.  We need the Jacobian for
% this, so it is initialized here.
if Jconstant
  DfDy = Jac;
elseif Janalytic
  DfDy = feval(Jac,t0,y0,Jargs{:});
  nPD = 1;
else 
  [DfDy,Joptions.fac,nF] = odenumjac(fun, {t0,y0,args{:}}, f0, Joptions);  
  Jfac = Joptions.fac;   % output
  nFE = nF;
  nPD = 1;
end

if Mtype == 4
  [dMypdy,dMoptions.fac] = odenumjac(@odemxv, {Mfun,t0,y0,yp0,Margs{:}}, M0*yp0, ...    
                                     dMoptions);    
  dMfac = dMoptions.fac; % output
end

needJ = false;

nrmDfDy = norm(DfDy,'fro');
nrmM0 = norm(M0,'fro');
if nrmM0 < absh*nrmDfDy
   absh = nrmM0/nrmDfDy;
end
% Impose a minimum step size and attach a sign to absh.
h = sign(t1 - t0)*max(absh, 4*eps*abs(t0));

% Output y, yp must have a residual no bigger than input y0, yp0.
best_norm = norm(M0*yp0 - f0);

for newh = 1:3                         % Begin loop on the parameter h.

  needLU = true;                       % Factor iteration matrix for each h.
  y = y0;
  f = f0;

  for pass = 1:2                       % Begin loop to get a "small" yp.
    yp = yp0;                          % Find a yp "close" to yp0.
    F = M0*yp - f; 
    converged = false;
    
    for iter = 1:15                    % Begin simplified Newton iterations.        
      if needJ 
        if ~Jconstant
          if Janalytic
            DfDy = feval(Jac,t0,y,Jargs{:});
            nPD = nPD + 1;
          else 
            [DfDy,Joptions.fac,nF] = odenumjac(fun, {t0,y,args{:}}, f, Joptions);  
            Jfac = Joptions.fac;   % output                                    
            nFE = nFE + nF;
            nPD = nPD + 1;
          end
        end  
        needJ = false;
        if Mtype >= 3
          M0 = feval(Mfun,t0,y,Margs{:});
        end
        if Mtype == 4
          [dMypdy,dMoptions.fac] = odenumjac(@odemxv, {Mfun,t0,y,yp,Margs{:}}, M0*yp, ...    
                                             dMoptions);    
          dMfac = dMoptions.fac;  % output
        end   
        needLU = true;      
      end
      
      if needLU
        J = M0/h - DfDy;
        if Mtype == 4
          J = J + dMypdy;
        end
        
        maxrow = max(abs(J),[],2);                  
        if any(maxrow == 0)   
          error('MATLAB:daeic3:IndexGTOne',...
                'This DAE appears to be of index greater than 1.')   
        end                             
        
        RowScale = 1 ./ maxrow;               
        J = spdiags(RowScale,0,neq,neq) * J;        
        [L,U] = lu(J);
        needLU = false;
      end      

      lastwarn('');
      dely = -(U \ (L \ (RowScale .* F)));  
      if ~isempty(lastwarn)
        error('MATLAB:daeic3:IndexGTOne',...
              'This DAE appears to be of index greater than 1.')   
      end
      
      res = norm(dely);            % Estimate the error of y.       
      % Weak line search with affine invariant test.
      lambda = 1;
      for probe = 1:3
        ynew = y + lambda*dely; 
        ypnew = (ynew - y0)/h;
        if Mtype >= 3
          M0 = feval(Mfun,t0,ynew,Margs{:});            
        end                        
        LHS = M0*ypnew;
        fnew = feval(fun,t0,ynew,args{:});
        nFE = nFE + 1;
        Fnew = LHS - fnew;       
        norm_Fnew = norm(Fnew);
        if (norm_Fnew <= 1e-3*reltol*max(norm(LHS),norm(fnew))) && (norm_Fnew <= best_norm)
          best_norm = norm_Fnew;          
          y = ynew;
          yp = ypnew;
          f = fnew;
          converged = true;
          break;
        end
        % Estimate the error of ynew.
        resnew = norm(U \ (L \ (RowScale .* Fnew)));    
        if resnew < 0.9*res
          break;
        else
          lambda = 0.5*lambda;
        end 
      end

      if converged
        break;
      end

      ynorm = max(norm(y),norm(ynew));      
      if ynorm == 0
        ynorm = eps;
      end 
      y = ynew;
      yp = ypnew;
      f = fnew;
      F = Fnew;      
      if (resnew <= 1e-3*reltol*ynorm) && (norm(F) <= best_norm)
        best_norm = norm(F);        
        converged = true;
        break;
      end
      needJ = (resnew > 0.1*res);         
    end  % End loop on simplified Newton iteration.
  
    if ~converged
      break;
    end
    
    y0 = y;                             % Second pass to get a "small" yp.
    if Mtype >= 3
      M0 = feval(Mfun,t0,y,Margs{:}); 
      needLU = true;
    end                           
  end  % End loop to get "small" yp.
  
  if ~converged
    h = h/10;
  else
    return;
  end
end  % End loop on parameter h.

error('MATLAB:daeic3:NeedBetterY0',...
      'Need a better guess y0 for consistent initial conditions.')
