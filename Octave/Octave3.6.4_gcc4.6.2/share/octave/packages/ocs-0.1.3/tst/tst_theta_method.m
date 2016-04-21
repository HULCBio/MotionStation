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
##
## @deftypefn{Function File} {[@var{out},@var{niter}] =}  tst_theta_method @
## (@var{cirstruct},@var{x},@var{t},@var{tol},@
## @var{maxit},@var{theta},@var{pltvars},@
## @var{verbosity});
##
## Perform a transient simulation of the system described by
## @var{cirstruct} over the time interval @var{t} using the
## theta-method with parameter @var{theta}.
##
## The initial value for the state vector is computed by solving a
## steady state problem at @var{t}(1), with starting guess @var{x}.
##
## @var{tol} and @var{maxit} are parameters passed to
## @code{nls_newton_raphson}.
##
## The output @var{out} will contain the value of the state vector at
## each point of @var{t}.
##
## The optional parameter @var{verbosity} controls the amount of
## output produced: 
## 
## @itemize @minus 
## @item if verbosity(1) != 0, information on the progress
## of the algorithm are output at runtime
## @item if verbosity(2) != 0, the plot of the variables whose names
## are listed in @var{pltvars} is
## produced after the computation
## @end itemize
## 
## The optional output @var{niter} returns the number of Newton iterations
## needed to reach convergence.
## 
## @seealso{tst_backward_euler,tst_daspk,tst_odepkg,nls_newton_raphson}
##
## @end deftypefn

function [out, varargout] = tst_theta_method(outstruct,x,t,tol,maxit,\
					     theta,pltvars,verbosity)

  ## Check input
  ## FIXME: add input check!
  if ((nargin < 7) || (nargin > 8))
    error("tst_theta_method: wrong number of input parameters.");
  endif

  if ~exist("verbosity")
    verbosity = [0,0];
  elseif length(verbosity)<2
    verbosity(2) = 0;
  endif

  out = zeros(rows(x),columns(t));
  out(:,1) = x;

  if nargout > 1
    niter = zeros(length(t),1);
  endif
  
  if (verbosity(1))
    fprintf(1,"Initial value.\n");
  endif
  
  
  [A0,B,C] = asm_initialize_system(outstruct,x);
  
  [out(:,1),ii] = nls_stationary(outstruct,x,tol,maxit);  

  if nargout > 1
    niter(1) = ii;
  endif

  for it=2:length(t)
    
    if(verbosity)
      fprintf(1,"Timestep #%d.\n",it);
    endif


    [A1old,Jacold,resold] = asm_build_system(outstruct, out(:,it-1), t(it-1));
    
    JAC = @(x,A1,Jac,res) TSTTHETAFUNJAC1(outstruct, x, t(it-1), 
					  t(it), A0, B, theta, 
					  A1, Jac, res);
    RES = @(x,A1,Jac,res) TSTTHETAFUNRES1(outstruct, x, out(:,it-1), 
					  t(it-1), t(it), A0, B, C, 
					  resold, theta, A1, Jac, res);
    UPDT = @(x) TSTTHETAFUNUP1 (outstruct, x, t(it));
    
    [out(:,it),ii,resnrm] = nls_newton_raphson(out(:,it-1),RES,JAC,\ 
					       tol, maxit,verbosity(1),\ 
					       UPDT);
    
    if nargout > 1
      niter(it) = ii;
    endif
        
    if (verbosity(2))
      utl_plot_by_name(t(1:it),out(:,1:it),outstruct,pltvars);
      pause(.1);
    endif
    
    if exist("~/.stop_ocs","file")
      break
    end
  endfor

  if nargout > 1
    varargout{1} = niter;
  endif

endfunction

## Jacobian for transient problem
function lhs = TSTTHETAFUNJAC1(outstruct, x, t0, t1, A0, B, theta, A1, Jac, res)

  DT = t1-t0;
  if ( nargin < 10 )
    [A1,Jac,res] = asm_build_system(outstruct,x,t1); 
  endif
  lhs = ( (A0+A1)/DT + theta*(B + Jac) ); 

endfunction
## Residual for transient problem
function rhs = TSTTHETAFUNRES1(outstruct, x, xold, t0, t1, A0, B, C, 
			       resold, theta, A1, Jac, res)
  DT = t1-t0;
  if ( nargin < 13 )
    [A1,Jac,res] = asm_build_system(outstruct,x,t1); 
  endif
  rhs = ( (A1+A0)*(x-xold)/DT  + theta * (res + C + B*x) + 
	 (1-theta) * (resold + C + B*xold) );

endfunction
## Update for transient problem
function update = TSTTHETAFUNUP1(outstruct,x,t1)

  [A1,Jac,res] = asm_build_system(outstruct,x,t1);
  update = {A1,Jac,res};

endfunction