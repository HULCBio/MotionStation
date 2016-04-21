function [y,yp,f,DfDy,nFE,nPD,fac] = ...
    daeic12(fun,args,t0,ICtype,M0,y,yp0,f,reltol,Jconstant,Jac,Jargs,Joptions)
%DAEIC12  Helper function to compute initial conditions of types 1 and 2.
%   DAEIC12 attempts to find a set of consistent initial conditions for
%   equations of the form M(t)*y' = f(t,y) when the mass matrix is diagonal
%   (ICtype = 1) and when the mass matrix is full (ICtype = 2).  t0 is the 
%   initial point, M0 is M(t0), y0 is a guess for y(t0), yp0 is a guess for 
%   y'(t0), f0 = f(t0,y0), and fun is a function for evaluating f(t,y).  
%   The output y and yp are such that M(t0)*yp = f(t0,y) is satisfied 
%   much more accurately than the relative error tolerance RelTol.  Only certain
%   components of y and yp can be specified; they have the values given by y0 and
%   yp0.  f is f(t0,y). DfDy is the Jacobian of f evaluated at (t0,y).  If the 
%   Jacobian was computed numerically, the quantities fac and g are returned for 
%   subsequent use, and otherwise they are returned as empty arrays.  The number 
%   of evaluations of odefile is provided by nFE and the number of evaluations of
%   the Jacobian is provided by nPD.
%   
%   See also DAEIC3, ODE15S, ODE23T.

%   Jacek Kierzenka, Lawrence F. Shampine, and Mark W. Reichelt, 12-18-97
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.16.4.3 $

fac = [];
nFE = 0;
nPD = 0;

neq = length(y);

Janalytic = isempty(Joptions);

if Jconstant
  DfDy = Jac;
elseif Janalytic
  DfDy = feval(Jac,t0,y,Jargs{:});
  nPD = 1;
else 
  [DfDy,Joptions.fac,nF] = odenumjac(fun, {t0,y,args{:}}, f, Joptions);  
  fac = Joptions.fac;   % output
  nFE = nF;
  nPD = 1;
end

if ICtype == 1
  D = diag(M0);
  if issparse(M0)
    UM = speye(size(M0));
    VM = UM;
  else
    UM = eye(size(M0));
    VM = UM;
  end
  AlgVar = find(D == 0);
else   % M0 is a full matrix.
  [UM,S,VM] = svd(M0);
  D = diag(S);
  tol = neq * max(D) * eps;
  AlgVar = find(D <= tol);
  D(AlgVar) = 0;
end
DifVar = find(D ~= 0);
F = UM' * f;
DFDY = UM' * DfDy * VM;
Y = VM' * y;
yp = VM' * yp0;

if isempty(AlgVar)
  % Arises only if MassSingular is yes, but the problem is not a DAE.
  yp = VM * (F ./ D);
  return;
end

J = DFDY(AlgVar,AlgVar); 
needJ = false;
% If J is singular, the problem is of index greater than 1:
if nnz(J) == 0 || eps*nnz(J)*condest(J) > 1 
  error('MATLAB:daeic12:IndexGTOne', 'This DAE appears to be of index greater than 1.')
end

% Check for consistency of initial guess.
if norm(F(AlgVar)) <= 1000*eps*norm(F)
  yp(DifVar) = F(DifVar) ./ D(DifVar);
  yp = VM * yp;
  return;
end

[L,U] = lu(J);

for iter = 1:15                         % Begin simplified Newton iterations.
  if needJ 
    if Janalytic
      DfDy = feval(Jac,t0,y,Jargs{:});
    else    
      [DfDy,Joptions.fac,nF] = odenumjac(fun, {t0,y,args{:}}, f, Joptions);  
      fac = Joptions.fac;   % output      
      nFE = nFE + nF;
    end
    DFDY = UM' * DfDy * VM;
    nPD = nPD + 1;
    J = DFDY(AlgVar,AlgVar);
    needJ = false;
    [L,U] = lu(J);
  end 
  
  delY = - (U \ (L \ F(AlgVar)));
  res = norm(delY);                     % Estimate the error.
  
  % Weak line search with affine invariant test.
  lambda = 1;
  Ynew = Y;
  for probe = 1:3
    Ynew(AlgVar) = Y(AlgVar) + lambda*delY;
    ynew = VM * Ynew;
    fnew = feval(fun,t0,ynew,args{:});
    Fnew = UM' * fnew;
    nFE = nFE + 1;
    if norm(Fnew(AlgVar)) <= 1e-3*reltol*norm(Fnew)
      y = ynew;
      f = fnew;
      yp(DifVar) = Fnew(DifVar) ./ D(DifVar);
      yp = VM * yp;
      return;
    end
    % Estimate the error of ynew.
    resnew = norm(U \ (L \ Fnew(AlgVar)));    
    if resnew < 0.9*res
      break;
    else
      lambda = 0.5*lambda;
    end 
  end

  Ynorm = max(norm(Y(AlgVar)),norm(Ynew(AlgVar)));      
  if Ynorm == 0
    Ynorm = eps;
  end 
  Y = Ynew;
  y = VM * Ynew;
  f = fnew;
  F = Fnew;
  if resnew <= 1e-3*reltol*Ynorm        
    yp(DifVar) = F(DifVar) ./ D(DifVar);
    yp = VM * yp;
    return;
  end
  needJ = (resnew > 0.1*res);
end  % End loop on simplified Newton iteration.

error('MATLAB:daeic12:NeedBetterY0',...
      'Need a better guess y0 for consistent initial conditions.')
