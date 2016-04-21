function NLS3
% NLS3: snls demo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This example demonstrates how to solve
% a structured nonlinear equation problem
% of the form F(x) = 0
% where F = G(y) and y is obtained by solving a sparse SPD
% system Ay = G(x). (in this example, G has a tridiagonal
% Jacobian matrix.) 
%
% NOTE: Components of the jacobian matrix are computed
%       but the explicit Jacobian is never actually formed.
%
% In the first run we supply special mtxmpy and pcmtx
% functions. 
%
% In the second run
% the newton step is computed
% by exploiting the structure of the problem
% and solving an `extended' system.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2004/02/07 19:13:17 $

% Initialization
m = 20;
n = m^2;

%  Get the structure of the matrix A: matrix S
load nlsdat3

fun = 'nlsf3a'; 
xstart = 15*ones(n,1);
%
% Choose a custom-made Jacobian-multiply routine, preconditioner
mtxmpy = 'nlsmm3'; precond = 'pceye';
%
% Set named parameter list, execute
options = optimset('tolfun',eps*10^6,'showstatus','iter','disp','iter','Jacobian','on','JacobMult',mtxmpy,'Precondi',precond) ;
[x,resnorm,fvec,exit,output,lambda] = lsqnonlin(fun,xstart,[],[],options,S);

return

%
% Second run -- compute custom-designed Newton step
% Note: the custom-designed Newton step is computed 
% if the user-supplied function fun = 'nlsf3';
% Initialization
m = 20;
n = m^2;
format long e
fun = 'nlsf3a'; xstart = 15*ones(n,1);
%
% Choose a custom-made Jacobian-multiply routine, preconditioner
mtxmpy = 'nlsmm3'; precond = 'pceye';
%
% Set named parameter list, execute
options = optimset('disp','iter','JacobMult',mtxmpy,'Precond',precond) ;
[x,resnorm,fvec,exit,output,lambda] = lsqnonlin(fun,xstart,[],[],options);

%
fun = 'nlsf3'; xstart = 15*ones(n,1);
%
% Choose a custom-made Jacobian-multiply routine
mtxmpy = 'nlsmm3';
%
% Set named parameter list, execute
options = optimset('disp','iter','JacobMult',mtxmpy) ;
[x,resnorm,fvec,exit,output,lambda] = lsqnonlin(fun,xstart,[],[],options);

