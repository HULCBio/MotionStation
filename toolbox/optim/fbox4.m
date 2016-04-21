function FBOX4
% FBOX4: sfmin demo
% to solve a problem of the form:
%
%        min { f(x) :  l <= x <= u}
%
% where f is a smooth mapping from n-vectors to scalars,
% l,u are (dense) n-vectors of lower and upper bounds respectively,
% and x is the n-vector of unknowns. 
%
% solves problem BROWNX
% The Hessian of BROWNX is tridiagonal + rank-2 outer-product (Y*Y^T).  
%
% We choose n = 1000.
% First run, UNCONSTRAINED version
%
% Initialize

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2004/02/07 19:13:02 $

n = 1000;
xstart=-ones(n,1); 
xstart(2:2:n,1)=ones(length(2:2:n),1);

fun = 'brownyy'; 
load fbox4 % Get matrix Y (1000-by-2)
mtx = 'hmfbx4';
%
% Set options and execute
options = optimset('tolx',1e-6,'tolfun',1e-10,'showstatus','iter',...
   'disp','iter','GradObj','on','Hessian','on','HessMult',mtx);
[x,FVAL,EXITFLAG,OUTPUT] = fminunc(fun,xstart,options,Y) ; 
%
% Same problem but use custom designed Newton step computation

return

%
% Initialize
fun = 'brownx2'; %Customized Newton step
%
% Set options and execute
options = optimset('Hessian','on','HessMult',mtx);
[x,FVAL,EXITFLAG,OUTPUT] = fminunc(fun,xstart,options,Y) ; 
