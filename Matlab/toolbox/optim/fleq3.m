function FLEQ3
% FLEQ3: sfmin demo
% to solve a problem of the form:
%
%        min { f(x) :  Ax = b}
%
% where f is a smooth mapping from n-vectors to scalars,
% l,u are (dense) n-vectors of lower and upper bounds respectively,
% and x is the n-vector of unknowns. 
%
% solves problem BROWNX
% The Hessian of BROWNX is tridiagonal + rank-2 outer-product (Y*Y^T).  
%
% We choose n = 1000.
%

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2004/02/07 19:13:10 $

% Initialize
  n = 1000;
  xstart=-ones(n,1); 
  xstart(2:2:n,1)=ones(length(2:2:n),1);
  
  fun = 'brownyy'; 
  
  load fbox4 % Get matrix Y (1000-by-2)
  
  mtx = 'hmfbx4';
  load fleq1 % Get matrix A, rhs b
%
% Set options and execute
  options = optimset('disp','iter','GradObj','on','Hessian','on','HessMult',mtx);
[x,FVAL,EXITFLAG,OUTPUT,LAMBDA] = fmincon(fun,xstart,[],[],A,b,[],[],[],options,Y) ; 
