## Copyright (C) 2006,2007,2008  Carlo de Falco            
##
## This file is part of:
## OCS - A Circuit Simulator for Octave
##
## OCS is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program (see the file LICENSE); if not,
## see <http://www.gnu.org/licenses/>.
##
## author: Carlo de Falco <cdf _AT_ users.sourceforge.net> 

## -*- texinfo -*-
## @deftypefn{Function File} {[@var{out}, @var{niter}]} = nls_stationary @
## (@var{instruct},@var{x},@var{tol},@var{maxit})
## Compute the stationary state solution @var{out} of the system described
## by @var{instruct}.
##
## @var{x} is the initial guess used by the Newton-Raphson algorithm implemented in
## @code{nls_newton_raphson}, while @var{tol} and @var{maxit} are the corresponding 
## parameters.
## 
## The optional output @var{niter} returns the number of Newton iterations
## needed to reach convergence.
##
## @seealso{nls_newton_raphson}
## @end deftypefn

function [out, varargout] = nls_stationary(outstruct,x,tol,maxit)

  ## Check input
  ## FIXME: add input check!
  if nargin != 4
    error("nls_stationary: wrong number of input parameters.");
  endif

  [A0,B,C] = asm_initialize_system(outstruct,x);
  JAC = @(x) TSTSTATFUNJAC(outstruct,x,B);
  RES = @(x) TSTSTATFUNRES(outstruct,x,B,C);
  UPD = @(x) TSTSTATUP(outstruct,x);
  [out,ii,resnrm] = nls_newton_raphson(x,RES,JAC,tol,maxit,0,UPD);

  if nargin > 1
    varargout{1} = ii;
  endif

endfunction

## Jacobian for steady state problems
function lhs = TSTSTATFUNJAC(outstruct,x,B,Jac,res)

  if nargin < 5
    [A1,Jac,res] = asm_build_system(outstruct,x,0);
  endif
  lhs = (B + Jac); 

endfunction
## Residual for steady state problem
function rhs = TSTSTATFUNRES(outstruct,x,B,C,Jac,res)

  if nargin < 6
    [A1,Jac,res] = asm_build_system(outstruct,x,0);
  endif
  rhs = (res + C + B*x);

endfunction
## Update for transient problem
function update = TSTSTATUP(outstruct,x)

  [A1,Jac,res] = asm_build_system(outstruct,x,0);
  update = {Jac,res};

endfunction